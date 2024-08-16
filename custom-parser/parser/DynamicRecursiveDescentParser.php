<?php
/*
@TODO:

* ✅ Tokenize MySQL Queries
* Memoize token nb/rule matches to avoid repeating work.
* Optimize the grammar to resolve ambiugities
* Parse tree -> AST. Or not? I think we'll be just fine with the parse tree
* Generate an expanded PHP parser to optimize matching, right now we're doing a 
  whole lot of lookups
*/


class Grammar {

    public $rules;
    public $rule_names;
    public $lookahead_which_branch = [];
    public $lookahead_is_match_possible = [];
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
        }

        /**
         * Compute a rule => [token => true] lookup table for each rule
         * that starts with a terminal OR with another rule that already
         * has a lookahead mapping.
         * 
         * This is similar to left-factoring the grammar, even if not quite
         * the same.
         * 
         * This enables us to quickly bale out from checking branches that 
         * cannot possibly match the current token. This increased the parser
         * speed by a whooping 80%!
         * 
         * The next step could be to:
         * 
         * * Compute a rule => [token => branch[]] list lookup table and only
         *   process the branches that have a chance of matching the current token.
         * * Actually left-factor the grammar as much as possible. This, however,
         *   could inflate the serialized grammar size.
         */
        // 5 iterations seem to give us all the speed gains we can get from this.
        for ($i = 0; $i < 5; $i++) {
            foreach ($grammar['grammar'] as $rule_index => $branches) {
                $rule_id = $rule_index + $grammar['rules_offset'];
                if(isset($this->lookahead_is_match_possible[$rule_id])) {
                    continue;
                }
                $rule_lookup = [];
                $first_symbol_can_be_expanded_to_all_terminals = true;
                foreach($branches as $branch) {
                    $terminals = false;
                    $branch_starts_with_terminal = $branch[0] < $this->lowest_non_terminal_id;
                    if($branch_starts_with_terminal) {
                        $terminals = [$branch[0]];
                    } else if(isset($this->lookahead_is_match_possible[$branch[0]])) {
                        $terminals = array_keys($this->lookahead_is_match_possible[$branch[0]]);
                    }

                    if($terminals === false) {
                        $first_symbol_can_be_expanded_to_all_terminals = false;
                        break;
                    }
                    foreach($terminals as $terminal) {
                        $rule_lookup[$terminal] = true;
                    }
                }
                if ($first_symbol_can_be_expanded_to_all_terminals) {
                    $this->lookahead_is_match_possible[$rule_id] = $rule_lookup;
                }
            }
        }
    }

}

class StackFrame {
    public $rule_id;
    public $starting_position = 0;
    public $position = 0;
    public $branch_index = 0;
    public $subrule_index = 0;
    public $match = [];
    public $child_frame;
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

    public function parse_start() {
        $result = $this->parse_recursive($this->grammar->get_rule_id("query"));
        return $result;
    }

    public function parse_recursive($rule_id) {
        $is_terminal = $rule_id <= $this->grammar->highest_terminal_id;
        if ($is_terminal) {
            ++$this->checks;
            // Inlining a $this->match($rule_id) call here speeds the
            // parser up by a whooping 10%!
            if ($this->position >= count($this->tokens)) {
                return null;
            }
    
            if ( MySQLLexer::EMPTY_TOKEN === $rule_id ) {
                return true;
            }
    
            if($this->tokens[$this->position]->type === $rule_id) {
                $this->position++;
                return $this->tokens[$this->position - 1] . '';
            }
            return null;
        }

        $rule = $this->grammar->rules[$rule_id];
        // Bale out from processing the current branch if none of its rules can
        // possibly match the current token.
        if(isset($this->grammar->lookahead_is_match_possible[$rule_id])) {
            $token_id = $this->tokens[$this->position]->type;
            if(
                !isset($this->grammar->lookahead_is_match_possible[$rule_id][$token_id]) &&
                !isset($this->grammar->lookahead_is_match_possible[$rule_id][MySQLLexer::EMPTY_TOKEN])
            ) {
                return null;
            }
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
                $matched_children = $this->parse_recursive($subrule_id);
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

    public $checks = 0;
    /**
     * This method is unused. It was an attempt to optimize the parser by unrolling
     * the recursion, but it was slower than the recursive version. Who would have
     * thought! I'm keeping it here for reference and future optimization ideas.
     */
    public function parse_without_recursion($rule_id) {
        $root_frame = new StackFrame();
        $root_frame->rule_id = $rule_id;
        $root_frame->position = 0;
        $root_frame->starting_position = 0;
        $stack = [$root_frame];
        while (!empty($stack)) {
            $frame = end($stack);
            if($frame->child_frame) {
                // We've just finished matching the nested rule!
                // It matched if there's one or more entries in the match array.
                if(count($frame->child_frame->match)) {
                    // echo $indent . 'Matched a subrule of frame ' . $this->get_rule_name($frame->rule_id) ." \n";
                    // It was a match! Move on to the next subrule.
                    ++$frame->subrule_index;
                    $frame->match[] = $frame->child_frame->match;
                    $frame->position = $frame->child_frame->position;
                } else {
                    // The subrule didn't match. Move on to the next branch in
                    // the current frame.
                    ++$frame->branch_index;
                    $frame->subrule_index = 0;
                    $frame->match = [];
                    $frame->position = $frame->starting_position;
                }
                $frame->child_frame = null;
            }

            $rule = $this->grammar->rules[$frame->rule_id];
            // Lookahead optimization – go directly to the branch that matches
            // if it's in our lookahead hash table.
            if ($frame->branch_index === 0 && $frame->subrule_index === 0 && isset($this->grammar->lookahead_which_branch[$frame->rule_id])) {
                $token_id = $this->tokens[$frame->position]->type;
                $branch_nb = false;
                if(isset($this->grammar->lookahead_which_branch[$frame->rule_id][$token_id])) {
                    $branch_nb = $this->grammar->lookahead_which_branch[$frame->rule_id][$token_id];
                } else if(isset($this->grammar->lookahead_which_branch[$frame->rule_id][MySQLLexer::EMPTY_TOKEN])) {
                    $branch_nb = $this->grammar->lookahead_which_branch[$frame->rule_id][MySQLLexer::EMPTY_TOKEN];
                }
                if ($branch_nb === false) {
                    $frame->match = [];
                    array_pop($stack);
                    continue;
                } else {
                    $frame->branch_index = $branch_nb;
                }
            }

            for (; $frame->branch_index < count($rule); $frame->branch_index++) {
                $branch = $rule[$frame->branch_index];
                for (; $frame->subrule_index < count($branch); $frame->subrule_index++) {
                    $subrule_id = $branch[$frame->subrule_index];

                    // $indent = str_repeat('  ', count($stack)) . 
                    //     '[' . $this->get_rule_name($frame->rule_id) .':'.($frame->branch_index.':'.$frame->subrule_index.':'.$frame->position) .
                    //     '][' . $this->get_rule_name($subrule_id) .']'
                    // ;

                    // Match a terminal – check if the current token satisfies the rule.
                    $is_terminal = $subrule_id <= $this->grammar->highest_terminal_id;
                    if ($is_terminal) {
                        ++$this->checks;
                        if ($frame->position < count($this->tokens) && (
                            MySQLLexer::EMPTY_TOKEN === $subrule_id ||
                            $this->tokens[$frame->position]->type === $subrule_id
                        )) {
                            // if($indent) echo $indent . 'Did match! ' .  " <".$this->tokens[$frame->position]."> \n";
                            // Match! Save it in the frame and move to the next subrule.
                            if(MySQLLexer::EMPTY_TOKEN === $subrule_id) {
                                $frame->match[] = true;
                            } else {
                                $frame->match[] = $this->tokens[$frame->position];
                                ++$frame->position;
                            }
                            continue;
                        } else {
                            // if($indent) echo $indent . 'Failed to match: ' . " <".$this->tokens[$frame->position]."> \n";
                            // No match. Break out of the subrule loop and try the next branch.
                            $frame->match = [];
                            $frame->position = $frame->starting_position;
                            $frame->subrule_index = 0;
                            break;
                        }
                    }
                    
                    // Match a non-terminal – push a new frame onto the stack and continue.
                    //
                    // This is a recursion unrolled as a loop. This is an attempt to get
                    // more speed than with a nested $this->parse() call. Unfortunately,
                    // this is both slower and more complex.
                    $child_frame = new StackFrame();
                    $child_frame->rule_id = $subrule_id;
                    $child_frame->position = $frame->position;
                    $child_frame->starting_position = $frame->position;
                    // if($indent) echo $indent . 'Pushing non-terminal to the stack! ' . " <".$this->tokens[$frame->position]."> \n";
                    $stack[] = $child_frame;

                    // Preserve the current stack frame, we'll want to re-enter it after
                    // we're done with processing the nested rule.
                    // But set a reference to the child frame so we can easily check if
                    // it matched later on.
                    $frame->child_frame = $child_frame;

                    continue 3;
                }
                if(count($frame->match)) {
                    // if($indent) echo $indent . "Branch matched!\n";
                    break;
                } else {
                    // if($indent) echo $indent . "Trying the next branch!\n";
                    $frame->match = [];
                    $frame->position = $frame->starting_position;
                }
            }

            array_pop($stack);

            // We've successfully matched the last subrule in the root frame.
            // We're done, yay!
            if(empty($stack)) {
                if (count($frame->match)) {
                    return $frame;
                }
            }
        }
    
        // We've exhausted all branches and subrules. No match.
        return null;
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
}

require_once __DIR__ . '/MySQLLexer.php';
function tokenizeQuery($sql) {
    $lexer = new MySQLLexer($sql);
    $tokens = [];
    do {
        $token = $lexer->getNextToken();
        $tokens[] = $token;
    } while ($token->type !== MySQLLexer::EOF);
    return $tokens;
}



$queries = [
    <<<SQL
WITH mytable AS (select 1) SELECT 123 FROM test
SQL,
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
// $parser = new DynamicRecursiveDescentParser($grammar, $tokens);
// $parse_tree = $parser->parse_start();
// var_dump($parse_tree);
// var_dump($parser->checks);
// die();


// foreach ($queries as $k => $query) {
//     $parser = new DynamicRecursiveDescentParser($grammar, tokenizeQuery($query), $lookup);
    // $parser->debug = true;
    // print_r($parse_tree);
//     file_put_contents("query_$k.parsetree", 
//     "QUERY:\n$query\n\nPARSE TREE:\n\n" . json_encode($parse_tree, JSON_PRETTY_PRINT));
// }

// die();
// Benchmark 5 times
echo 'all loaded and deflated'."\n";
$tokens = tokenizeQuery($queries[3]);

$start_time = microtime(true);
for ($i = 0; $i < 700; $i++) {
    $parser = new DynamicRecursiveDescentParser($grammar, $tokens);
    $parse_tree = $parser->parse_start();
}
var_Dump($parser->checks);
$end_time = microtime(true);
$execution_time = $end_time - $start_time;

// // Output the parse tree
echo json_encode($parse_tree, JSON_PRETTY_PRINT);

// // Output the benchmark result
echo "Execution time: " . $execution_time . " seconds";
