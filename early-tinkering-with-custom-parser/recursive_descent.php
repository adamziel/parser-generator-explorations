<?php

class SQLParser {
    private $tokens;
    private $position;

    public function __construct($tokens) {
        $this->tokens = $tokens;
        $this->position = 0;
    }

    public function parse() {
        return $this->parseSelectStatement();
    }

    private function matchToken($expectedToken) {
        if ($this->position < count($this->tokens) && ($this->tokens[$this->position] == $expectedToken || $expectedToken == 'IDENTIFIER')) {
            $this->position++;
            return true;
        }
        return false;
    }

    private function parseSelectstatement() {
        $startPosition = $this->position;
        $node = ['rule' => 'selectStatement', 'children' => []];

        $childNode = $this->parseSelectstatement();
        if ($childNode === null) {
            $this->position = $startPosition;
            return null;
        }
        $node['children'][] = $childNode;

        $firstNode = $this->parseSelectstatement();
        if ($firstNode === null) {
            $this->position = $startPosition;
            return null;
        }
        $node['children'][] = $firstNode;
        
        while (true) {
            $childNode = $this->parseSelectstatement();
            if ($childNode === null) {
                break;
            }
            $node['children'][] = $childNode;
        }

        $childNode = $this->parseSelectstatement();
        if ($childNode !== null) {
            $node['children'][] = $childNode;
        }

        while (true) {
            $childNode = $this->parseSelectstatement();
            if ($childNode === null) {
                break;
            }
            $node['children'][] = $childNode;
        }

        return $node;
    }
    private function parseSelecttoken() {
        $startPosition = $this->position;
        $node = ['rule' => 'selectToken', 'children' => []];

        if (!$this->matchToken('SELECT')) {
            $this->position = $startPosition;
            return null;
        }
        $node['children'][] = ['rule' => 'SELECT', 'token' => $this->tokens[$this->position - 1]];

        return $node;
    }
    private function parseColumn() {
        $startPosition = $this->position;
        $node = ['rule' => 'column', 'children' => []];

        if (!$this->matchToken('IDENTIFIER')) {
            $this->position = $startPosition;
            return null;
        }
        $node['children'][] = ['rule' => 'IDENTIFIER', 'token' => $this->tokens[$this->position - 1]];

        return $node;
    }
    private function parseFromsection() {
        $startPosition = $this->position;
        $node = ['rule' => 'fromSection', 'children' => []];

        if (!$this->matchToken('FROM')) {
            $this->position = $startPosition;
            return null;
        }
        $node['children'][] = ['rule' => 'FROM', 'token' => $this->tokens[$this->position - 1]];

        if (!$this->matchToken('IDENTIFIER')) {
            $this->position = $startPosition;
            return null;
        }
        $node['children'][] = ['rule' => 'IDENTIFIER', 'token' => $this->tokens[$this->position - 1]];

        return $node;
    }
    private function parseJoinsection() {
        $startPosition = $this->position;
        $node = ['rule' => 'joinSection', 'children' => []];

        if (!$this->matchToken('JOIN')) {
            $this->position = $startPosition;
            return null;
        }
        $node['children'][] = ['rule' => 'JOIN', 'token' => $this->tokens[$this->position - 1]];

        if (!$this->matchToken('IDENTIFIER')) {
            $this->position = $startPosition;
            return null;
        }
        $node['children'][] = ['rule' => 'IDENTIFIER', 'token' => $this->tokens[$this->position - 1]];

        if (!$this->matchToken('ON')) {
            $this->position = $startPosition;
            return null;
        }
        $node['children'][] = ['rule' => 'ON', 'token' => $this->tokens[$this->position - 1]];

        if (!$this->matchToken('IDENTIFIER')) {
            $this->position = $startPosition;
            return null;
        }
        $node['children'][] = ['rule' => 'IDENTIFIER', 'token' => $this->tokens[$this->position - 1]];

        $childNode = $this->parseJoinsection();
        if ($childNode === null) {
            $this->position = $startPosition;
            return null;
        }
        $node['children'][] = $childNode;

        if (!$this->matchToken('IDENTIFIER')) {
            $this->position = $startPosition;
            return null;
        }
        $node['children'][] = ['rule' => 'IDENTIFIER', 'token' => $this->tokens[$this->position - 1]];

        return $node;
    }
}

$tokens = ['SELECT', 'IDENTIFIER', 'FROM', 'IDENTIFIER', 'JOIN', 'IDENTIFIER', 'ON', 'IDENTIFIER', 'IDENTIFIER'];
$parser = new SQLParser($tokens);
$ast = $parser->parse();
print_r($ast);
