<?php
/*
@TODO:

* ✅ Tokenize MySQL Queries
* Optimize the grammar to resolve ambiugities
* Parse tree -> AST. Or not? I think we'll be just fine with the parse tree
* Generate an expanded PHP parser to optimize matching, right now we're doing a 
  whole lot of lookups
*/


class Grammar {

    public $rules;
    public $rule_names;
    public $terminals_lookup;
    public $lowest_non_terminal_id;
    public $highest_terminal_id;

    public function __construct(array $rules, array $lookup_table = null)
    {
        $this->inflate($rules);
    }

    public function get_rule_name($rule_id) {
        return $this->rule_names[$rule_id];
    }

    public function get_rule_id($rule_name) {
        return array_search($rule_name, $this->rule_names);
    }

    /**
     * Grammar is a packed PHP array to minimize the file size. Every
     * rule and token is encoded as an integer. It still takes 1.2MB,
     * maybe we can do better than that with a more efficient encoding,
     * e.g. what Dennis Snell did for the HTML entity decoder.
     * Or maybe we can reduce the grammar size by factoring the rules?
     * Or perhaps we can let go of some parsing rules that SQLite cannot
     * support anyway?
     */
    private function inflate($grammar)
    {
        $this->lowest_non_terminal_id = $grammar['rules_offset'];
        $this->highest_terminal_id = $this->lowest_non_terminal_id - 1;

        foreach($grammar['rules_names'] as $rule_index => $rule_name) {
            $this->rule_names[$rule_index + $grammar['rules_offset']] = $rule_name;
            $this->rules[$rule_index + $grammar['rules_offset']] = [];
        }

        $this->rules = [];
        foreach($grammar['grammar'] as $rule_index => $branches) {
            $rule_id = $rule_index + $grammar['rules_offset'];
            $this->rules[$rule_id] = $branches;

            $rule_lookup = [];
            $each_first_symbol_is_a_unique_terminal = true;
            foreach($branches as $k => $branch) {
                $branch_starts_with_terminal = $branch[0] < $this->lowest_non_terminal_id;
                if (!$branch_starts_with_terminal) {
                    $each_first_symbol_is_a_unique_terminal = false;
                    break;
                }
                if (isset($rule_lookup[$branch[0]])) {
                    $each_first_symbol_is_a_unique_terminal = false;
                    break;
                }
                $rule_lookup[$branch[0]] = $k;
            }
            if ($each_first_symbol_is_a_unique_terminal) {
                $this->terminals_lookup[$rule_id] = $rule_lookup;
            }
        }
    }

}

class DynamicRecursiveDescentParser {
    private $path;
    private $tokens;
    private $position;
    private Grammar $grammar;
    public $debug = false;

    public function __construct(Grammar $grammar, array $tokens) {
        $this->grammar = $grammar;
        $this->path = [];
        $this->tokens = $tokens;
        $this->position = 0;
    }

    public function parse_start() : ?array {
        $result = $this->parse($this->grammar->get_rule_id("query"));
        return $result;
    }

    public function parse($rule_id) {
        $is_terminal = $rule_id <= $this->grammar->highest_terminal_id;
        if ($is_terminal) {
            return $this->_match_token($rule_id);
        }

        $rule = $this->grammar->rules[$rule_id];
        if(isset($this->grammar->terminals_lookup[$rule_id])) {
            $token_id = $this->tokens[$this->position]->getType();
            $branch_nb = false;
            if(isset($this->grammar->terminals_lookup[$rule_id][$token_id])) {
                $branch_nb = $this->grammar->terminals_lookup[$rule_id][$token_id];
            }
            if($branch_nb === false) {
                if(isset($this->grammar->terminals_lookup[$rule_id][MySQLLexer::EMPTY_TOKEN])) {
                    $branch_nb = $this->grammar->terminals_lookup[$rule_id][MySQLLexer::EMPTY_TOKEN];
                }
            }
            if($branch_nb === false) {
                return null;
            }

            $rule = [$rule[$branch_nb]];
        }

        $starting_position = $this->position;

        array_push($this->path, $rule_id);
        // $this->log('Before foreach(): '. $this->get_rule_name($rule_id). '<'.$rule_id.'> (' . count($rule).' branches)');
        foreach ($rule as $branch) {
            // $this->log('Entering branch: ' . $k);
            $this->position = $starting_position;
            $match = [];
            $branch_matches = true;
            foreach ($branch as $subrule_id) {
                $matched_children = $this->parse($subrule_id);
                if ($matched_children === null) {
                    // $this->log("Short-circuiting matching match branch $k ({$subrule['name']})");
                    $branch_matches = false;
                    break;
                } else if($matched_children === true) {
                    continue;
                } else if(is_array($matched_children) && count($matched_children) === 0) {
                    continue;
                }
                $match[$subrule_id][] = $matched_children;
            }
            if ($branch_matches === true) {
                // $this->log("Matched branch: " . $rule_id . '<' . $this->tokens[$starting_position] . '> <-> '. '<' . (isset($this->tokens[$this->position]) ? $this->tokens[$this->position] : '') . '>');
                break;
            } else {
                // $this->log("Failed to match branch: " . $this->get_rule_name($rule_id));
            }
        }
        // $this->log("Done with matching branches for $rule_or_terminal");
        array_pop($this->path);

        if (!$branch_matches) {
            $this->position = $starting_position;
            return null;
        }

        return $match;
    }

    private function get_rule_name($id)
    {
        if($id <= $this->grammar->highest_terminal_id) {
            return MySQLLexer::getTokenName($id);
        }

        return $this->grammar->get_rule_name($id);        
    }

    private function log($data) {
        if ($this->debug) {
            // Debugging utility
            $depth = count($this->path);
            echo str_repeat('  ', $depth) . $data . PHP_EOL;
        }
    }

    private function _match_token($token_id) {
        if ($this->position >= count($this->tokens)) {
            return null;
        }

        if ( MySQLLexer::EMPTY_TOKEN === $token_id ) {
            return true;
        }

        if($this->tokens[$this->position]->getType() === $token_id) {
            $this->position++;
            return $this->tokens[$this->position - 1] . '';
        }
        return null;
    }

}

require_once __DIR__ . '/MySQLLexer.php';
function tokenizeQuery($sql) {
    $lexer = new MySQLLexer($sql);
    $tokens = [];
    do {
        $token = $lexer->getNextToken();
        $tokens[] = $token;
    } while ($token->getType() !== MySQLLexer::EOF);
    return $tokens;
}



$queries = [
    <<<SQL
WITH mytable AS (select 1 as a, `b`.c from dual) 
SELECT HIGH_PRIORITY DISTINCT
	CONCAT("a", "b"),
	UPPER(z),
    DATE_FORMAT(col_a, '%Y-%m-%d %H:%i:%s') as formatted_date,
    DATE_ADD(col_b, INTERVAL 1 DAY) as date_plus_one,
	col_a
FROM 
my_table FORCE INDEX (`idx_department_id`),
(SELECT `mycol`, 997482686 FROM "mytable") as subquery
LEFT JOIN (SELECT a_column_yo from mytable) as t2 
    ON (t2.id = mytable.id AND t2.id = 1)
WHERE 1 = 3
GROUP BY col_a, col_b
HAVING 1 = 2
UNION SELECT * from table_cde
ORDER BY col_a DESC, col_b ASC
FOR UPDATE;
;
SQL,
    <<<SQL
CREATE TABLE products (
    product_id INT AUTO_INCREMENT PRIMARY KEY,
    product_name VARCHAR(100) NOT NULL,
    `description` TEXT,
    category ENUM('Electronics', 'Clothing', 'Books', 'Home', 'Beauty'),
    order_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT,
    product_id INT,
    `status` SET('Pending', 'Shipped', 'Delivered', 'Cancelled'),
    order_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    delivery_date DATETIME,
    CONSTRAINT fk_customer
        FOREIGN KEY (customer_id) REFERENCES customers (customer_id)
        ON DELETE CASCADE,
    CONSTRAINT fk_product
        FOREIGN KEY (product_id) REFERENCES products (product_id)
        ON DELETE CASCADE,
    INDEX idx_col_h_i (`col_h`, `col_i`),
    INDEX idx_col_g (`col_g`),
    UNIQUE INDEX idx_col_k (`col_k`),
    FULLTEXT INDEX idx_col_l (`col_l`)
) DEFAULT CHARACTER SET cp1250 COLLATE cp1250_general_ci;
SQL,
    <<<SQL
GRANT SELECT ON mytable TO myuser@localhost
SQL,
    <<<SQL
INSERT INTO products
SELECT 
    'Smartphone', 
    'Latest model with advanced features', 
    699.99, 
    50, 
    'Electronics'
WHERE NOT EXISTS (
    SELECT 1 FROM products WHERE product_name = 'Smartphone'
) AND 1=2;
SQL
];

$lookup = json_decode(file_get_contents(__DIR__.'/lookup-branches.json'), true);
// Assuming MySQLParser.json is in the same directory as this script
$grammar_data = include "./grammar.php";
$grammar = new Grammar($grammar_data, $lookup);

$tokens = tokenizeQuery($queries[0]);
$parser = new DynamicRecursiveDescentParser($grammar, $tokens);
// foreach ($queries as $k => $query) {
//     $parser = new DynamicRecursiveDescentParser($grammar, tokenizeQuery($query), $lookup);
    // $parser->debug = true;
    // $parse_tree = $parser->parse_start();
    // print_r($parse_tree);
//     file_put_contents("query_$k.parsetree", 
//     "QUERY:\n$query\n\nPARSE TREE:\n\n" . json_encode($parse_tree, JSON_PRETTY_PRINT));
// }

// die();
// Benchmark 5 times
$tokens = tokenizeQuery($queries[0]);

$start_time = microtime(true);
for ($i = 0; $i < 100; $i++) {
    $parser = new DynamicRecursiveDescentParser($grammar, $tokens);
    $parse_tree = $parser->parse_start();
}
$end_time = microtime(true);
$execution_time = $end_time - $start_time;

// // Output the parse tree
echo json_encode($parse_tree, JSON_PRETTY_PRINT);

// // Output the benchmark result
echo "Execution time: " . $execution_time . " seconds";
