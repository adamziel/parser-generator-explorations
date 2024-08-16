import { Grammars, Parser } from 'ebnf';
import fs from 'fs';

let grammar = fs.readFileSync('MySQLFull.ebnf', 'utf8');
const RULES = Grammars.W3C.getRules(grammar);

const rulesMap = {};
for (const rule of RULES) {
    rulesMap[rule.name] = rule;
}

function ruleToPeginator(name, topLevel=true) {
    const ref = rulesMap[name.replace(/[?*+]$/, '')];
    const newRule = [];
    for (const rulesList of ref.bnf) {
        newRule.push(processRulesList(rulesList));
    }
    let newRuleString = newRule.join(' | ');
    if (topLevel) {
        newRuleString = `${name} = ${newRuleString};`;
        if (newRuleString.includes('/[')) {
            newRuleString = `\n@char\n${newRuleString}`;
        }
    }
    return newRuleString;
}

function processRulesList(rulesList) {
    let newRule = [];
    for (const subrule of rulesList) {
        if (!(typeof subrule === 'string')) {
            // Could be a regexp
            if (subrule instanceof RegExp) {
                newRule.push(subrule.toString());
                continue;
            }
        }
        const ref = rulesMap[subrule];
        let wrapInParens = false;
        let newSubrule = subrule;
        if (subrule.match(/^%/)) {
            newSubrule = ruleToPeginator(newSubrule, false);
            wrapInParens = true;
        }
        if (subrule[subrule.length - 1] === '?') {
            newSubrule = `[${trimRight(newSubrule, '?')}]`;
            wrapInParens = false;
        } else if (subrule[subrule.length - 1] === '*') {
            newSubrule = `{${trimRight(newSubrule, '*')}}`;
            wrapInParens = false;
        } else if (subrule[subrule.length - 1] === '+') {
            newSubrule = `{${trimRight(newSubrule, '+')}}+`;
            wrapInParens = false;
        }
        if (wrapInParens) {
            newSubrule = `(${newSubrule})`;
        }
        newRule.push(newSubrule);
    }
    // if (newRule.length > 1) {
        // newRule = newRule.map(r => `${r}`);
    // }
    return newRule.join(' ');
}

function trimRight(string, char) {
    while (string[string.length - 1] === char) {
        string = string.substring(0, string.length - 1);
    }
    return string;
}

// console.log(ruleToPeginator('BACK_TICK_QUOTED_ID'));

let i = 0;
for (const rule of RULES) {
    if(rule.name.match(/^%/)) {
        continue;
    }
    console.log(ruleToPeginator(rule.name));
}
