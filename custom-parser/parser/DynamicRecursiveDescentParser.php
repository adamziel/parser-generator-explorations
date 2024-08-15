<?php
/*
@TODO:

* ✅ Tokenize MySQL Queries
* Optimize the grammar to resolve ambiugities
* Parse tree -> AST. Or not? I think we'll be just fine with the parse tree
* Generate an expanded PHP parser to optimize matching, right now we're doing a 
  whole lot of lookups
*/

class DynamicRecursiveDescentParser {
    private $path;
    private $tokens;
    private $position;
    private $grammar;
    private $rule_names;
    public $debug = false;

    public function __construct(array $grammar, array $tokens) {
        $this->grammar = $this->inflate_grammar($grammar);

        $this->path = [];
        $this->tokens = $tokens;
        $this->position = 0;
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
    private function inflate_grammar($grammar)
    {
        foreach($grammar['rules_names'] as $rule_id => $rule_name) {
            $this->rule_names[$rule_id + $grammar['rules_offset']] = $rule_name;
        }
        $inflated_grammar = [];
        foreach($grammar['grammar'] as $rule_id_without_offset => $branches) {
            $rule_id = $rule_id_without_offset + $grammar['rules_offset'];
            $rule_name = $this->rule_names[$rule_id];
            $inflated_grammar[$rule_name] = [];
            foreach($branches as $branch) {
                $new_branch = [];
                foreach($branch as $subrule_id) {
                    $new_branch[] = isset($this->rule_names[$subrule_id]) ? $this->rule_names[$subrule_id] : $subrule_id;
                }
                $inflated_grammar[$rule_name][] = $new_branch;
            }
        }
        return $inflated_grammar;        
    }

    public function parse_start() : ?array {
        $result = $this->parse("query");
        return $result;
    }

    public function parse($rule_or_terminal) {
        $is_terminal = !isset($this->grammar[$rule_or_terminal]);
        if ($is_terminal) {
            return $this->_match_token($rule_or_terminal);
        }

        $rule = $this->grammar[$rule_or_terminal];

        $starting_position = $this->position;
        array_push($this->path, $rule_or_terminal);
        // $this->log('Before foreach(): '. $rule_or_terminal. ' (' . count($rule).' branches)');
        foreach ($rule as $k => $branch) {
            $this->log('Entering branch: ' . $k);
            $this->position = $starting_position;
            $match = [];
            $branch_matches = true;
            foreach ($branch as $name) {
                $token_repr = ctype_digit($name.'') ? ( '<'.MySQLLexer::getTokenName($name).'>') : '';
                $this->log('Trying to match subrule: ' . $name . $token_repr);
                $matched_children = $this->parse($name);

                if ($matched_children === null) {
                    // $this->log("Short-circuiting matching match branch $k ({$subrule['name']})");
                    $branch_matches = false;
                    break;
                } else if($matched_children === true) {
                    continue;
                } else if(is_array($matched_children) && count($matched_children) === 0) {
                    continue;
                }
                $match[$name][] = $matched_children;
            }
            if ($branch_matches === true) {
                $this->log("Matched branch: " . $rule_or_terminal . '<' . $this->tokens[$starting_position] . '> <-> '. '<' . (isset($this->tokens[$this->position]) ? $this->tokens[$this->position] : '') . '>');
                break;
            } else {
                $this->log("Failed to match branch: " . $name);
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


function inflate_grammar(array $grammar) : array {
    $expanded_grammar = [];
    foreach ($grammar as $rule) {
        $expanded_grammar[$rule["name"]] = [];
    }
    foreach ($grammar as $rule) {
        foreach ($rule["bnf"] as $branch) {
            $new_branch = [];
            foreach ($branch as $name) {
                $is_terminal = !isset($expanded_grammar[$name]);
                $new_branch[] = $is_terminal ? MySQLLexer::getTokenId($name) : $name;
            }
            $expanded_grammar[$rule["name"]][] = $new_branch;
        }
    }
    return $expanded_grammar;
}

// Assuming MySQLParser.json is in the same directory as this script
$grammar = include "./grammar.php";

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

foreach ($queries as $k => $query) {
    $parser = new DynamicRecursiveDescentParser($grammar, tokenizeQuery($query));
    // $parser->debug = true;
    $parse_tree = $parser->parse_start();
    file_put_contents("query_$k.parsetree", 
    "QUERY:\n$query\n\nPARSE TREE:\n\n" . json_encode($parse_tree, JSON_PRETTY_PRINT));
}

// // Benchmark 5 times
// $start_time = microtime(true);
// for ($i = 0; $i < 50; $i++) {
//     $parser = new DynamicRecursiveDescentParser($expanded_grammar, $tokens);
//     $parse_tree = $parser->parse_start();
// }
// $end_time = microtime(true);
// $execution_time = $end_time - $start_time;

// // Output the parse tree
// echo json_encode($parse_tree, JSON_PRETTY_PRINT);

// // Output the benchmark result
// echo "Execution time: " . $execution_time . " seconds";
