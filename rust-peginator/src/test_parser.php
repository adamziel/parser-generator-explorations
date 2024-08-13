<?php

class FunctionDef {
    public $name;
    public $param_list;
    public $return_value;

    public function __construct($name, $param_list, $return_value) {
        $this->name = $name;
        $this->param_list = $param_list;
        $this->return_value = $return_value;
    }
}

class ParamList {
    public $self_param;
    public $params;

    public function __construct($self_param, $params) {
        $this->self_param = $self_param;
        $this->params = $params;
    }
}

class Param {
    public $name;
    public $typ;

    public function __construct($name, $typ) {
        $this->name = $name;
        $this->typ = $typ;
    }
}

class SelfParam {
    public $ref_type;

    public function __construct($ref_type) {
        $this->ref_type = $ref_type;
    }
}

class Type {
    public $ref_type;
    public $typename;

    public function __construct($ref_type, $typename) {
        $this->ref_type = $ref_type;
        $this->typename = $typename;
    }
}

abstract class ReferenceMarker {
    
}

class ImmutableReference extends ReferenceMarker {
}

class MutableReference extends ReferenceMarker {
}

class ParseState {
    public $input;
    public $offset;

    public function __construct($input, $offset = 0) {
        $this->input = $input;
        $this->offset = $offset;
    }

    public function slice($length) {
        return substr($this->input, $this->offset, $length);
    }

    public function advance($length) {
        $this->offset += $length;
    }
}

function parse_FunctionDef(ParseState $state) {
    $state_0 = clone $state;

    if (parse_Whitespace($state) && parse_string_literal($state, "fn")) {
        if (parse_Whitespace($state)) {
            $name = parse_Ident($state);
            if ($name !== null) {
                if (parse_Whitespace($state) && parse_character_literal($state, '(')) {
                    if (parse_Whitespace($state)) {
                        $param_list = parse_ParamList($state);
                        if ($param_list !== null) {
                            if (parse_Whitespace($state) && parse_character_literal($state, ')')) {
                                $return_value = parse_FunctionDef_part_5($state);
                                if ($return_value !== null) {
                                    return new FunctionDef($name, $param_list, $return_value);
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    $state->offset = $state_0->offset;
    return null;
}

function parse_FunctionDef_part_5(ParseState $state) {
    $state_0 = clone $state;

    if (parse_Whitespace($state) && parse_string_literal($state, "->")) {
        if (parse_Whitespace($state)) {
            $return_value = parse_Type($state);
            if ($return_value !== null) {
                return $return_value;
            }
        }
    }

    $state->offset = $state_0->offset;
    return null;
}

function parse_ParamList(ParseState $state) {
    $state_0 = clone $state;

    $self_param = null;
    if (parse_Whitespace($state)) {
        $self_param = parse_SelfParam($state);
    }

    if ($self_param !== null) {
        $params = [];
        while (true) {
            $state_1 = clone $state;
            if (parse_Whitespace($state) && parse_character_literal($state, ',')) {
                if (parse_Whitespace($state)) {
                    $param = parse_Param($state);
                    if ($param !== null) {
                        $params[] = $param;
                        continue;
                    }
                }
            }
            $state->offset = $state_1->offset;
            break;
        }

        return new ParamList($self_param, $params);
    }

    $state->offset = $state_0->offset;

    $state_2 = clone $state;

    $params = [];
    if (parse_Whitespace($state)) {
        $param = parse_Param($state);
        if ($param !== null) {
            $params[] = $param;

            while (true) {
                $state_3 = clone $state;
                if (parse_Whitespace($state) && parse_character_literal($state, ',')) {
                    if (parse_Whitespace($state)) {
                        $param = parse_Param($state);
                        if ($param !== null) {
                            $params[] = $param;
                            continue;
                        }
                    }
                }
                $state->offset = $state_3->offset;
                break;
            }

            return new ParamList(null, $params);
        }
    }

    $state->offset = $state_2->offset;

    $state_4 = clone $state;

    return new ParamList(null, []);

    $state->offset = $state_4->offset;

    return null;
}

function parse_Param(ParseState $state) {
    $state_0 = clone $state;

    if (parse_Whitespace($state)) {
        $name = parse_Ident($state);
        if ($name !== null) {
            if (parse_Whitespace($state) && parse_character_literal($state, ':')) {
                if (parse_Whitespace($state)) {
                    $typ = parse_Type($state);
                    if ($typ !== null) {
                        return new Param($name, $typ);
                    }
                }
            }
        }
    }

    $state->offset = $state_0->offset;
    return null;
}

function parse_SelfParam(ParseState $state) {
    $state_0 = clone $state;

    $ref_type = null;
    if (parse_Whitespace($state)) {
        $ref_type = parse_ReferenceMarker($state);
    }

    if ($ref_type !== null) {
        if (parse_Whitespace($state) && parse_string_literal($state, "self")) {
            return new SelfParam($ref_type);
        }
    }

    $state->offset = $state_0->offset;
    return null;
}

function parse_Type(ParseState $state) {
    $state_0 = clone $state;

    $ref_type = null;
    if (parse_Whitespace($state)) {
        $ref_type = parse_ReferenceMarker($state);
    }

    if ($ref_type !== null) {
        if (parse_Whitespace($state)) {
            $typename = parse_Ident($state);
            if ($typename !== null) {
                return new Type($ref_type, $typename);
            }
        }
    }

    $state->offset = $state_0->offset;
    return null;
}

function parse_ReferenceMarker(ParseState $state) {
    $state_0 = clone $state;

    if (parse_Whitespace($state)) {
        $mutable_reference = parse_MutableReference($state);
        if ($mutable_reference !== null) {
            return $mutable_reference;
        }
    }

    $state->offset = $state_0->offset;

    $state_1 = clone $state;

    if (parse_Whitespace($state)) {
        $immutable_reference = parse_ImmutableReference($state);
        if ($immutable_reference !== null) {
            return $immutable_reference;
        }
    }

    $state->offset = $state_1->offset;

    return null;
}

function parse_ImmutableReference(ParseState $state) {
    if (parse_Whitespace($state) && parse_character_literal($state, '&')) {
        return new ImmutableReference();
    }

    return null;
}

function parse_MutableReference(ParseState $state) {
    $state_0 = clone $state;

    if (parse_Whitespace($state) && parse_character_literal($state, '&')) {
        if (parse_Whitespace($state) && parse_string_literal($state, "mut")) {
            return new MutableReference();
        }
    }

    $state->offset = $state_0->offset;
    return null;
}

function parse_Ident(ParseState $state) {
    $state_0 = clone $state;

    while (true) {
        $state_1 = clone $state;
        if (parse_character_range($state, 'a', 'z') !== null) {
            continue;
        }
        $state->offset = $state_1->offset;

        $state_2 = clone $state;
        if (parse_character_range($state, 'A', 'Z') !== null) {
            continue;
        }
        $state->offset = $state_2->offset;

        $state_3 = clone $state;
        if (parse_character_literal($state, '_') !== null) {
            continue;
        }
        $state->offset = $state_3->offset;

        $state_4 = clone $state;
        if (parse_character_range($state, '0', '9') !== null) {
            continue;
        }
        $state->offset = $state_4->offset;

        break;
    }

    $ident = substr($state_0->input, $state_0->offset, $state->offset - $state_0->offset);

    if (strlen($ident) > 0) {
        return $ident;
    }

    $state->offset = $state_0->offset;
    return null;
}

function parse_Whitespace(ParseState $state) {
    while (true) {
        $state_0 = clone $state;
        if (parse_character_literal($state, ' ') !== null) {
            continue;
        }
        $state->offset = $state_0->offset;

        $state_1 = clone $state;
        if (parse_character_literal($state, '\t') !== null) {
            continue;
        }
        $state->offset = $state_1->offset;

        $state_2 = clone $state;
        if (parse_character_literal($state, '\n') !== null) {
            continue;
        }
        $state->offset = $state_2->offset;

        $state_3 = clone $state;
        if (parse_character_literal($state, '\r') !== null) {
            continue;
        }
        $state->offset = $state_3->offset;

        break;
    }

    return true;
}

function parse_string_literal(ParseState $state, $literal) {
    if (substr($state->input, $state->offset, strlen($literal)) === $literal) {
        $state->advance(strlen($literal));
        return true;
    }

    return null;
}

function parse_character_literal(ParseState $state, $literal) {
    if ($state->slice(1) === $literal) {
        $state->advance(1);
        return true;
    }

    return null;
}

function parse_character_range(ParseState $state, $start, $end) {
    $char = $state->slice(1);
    if ($char >= $start && $char <= $end) {
        $state->advance(1);
        return true;
    }

    return null;
}
