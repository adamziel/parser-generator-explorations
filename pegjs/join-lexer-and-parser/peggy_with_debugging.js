const peggy = require('peggy');

const fs = require('fs'); 
const Tracer = require('pegjs-backtrace');
const grammar = fs.readFileSync('mysql.pegjs', 'utf8')
const grammarLines = grammar.split('\n');

const parser = peggy.generate(grammar, {
    trace: true
});

const input = "SELECT`a`FROM,FROM`my_table`;";

const tracer = {
    trace: function (event) {
        if (event.type === 'rule.enter') {
            const start = event.location.start;
            const end = event.location.end;

            console.log(`${event.type}: ${event.rule}`, event.result);
        }
    }
};

const parsed = parser.parse(input, { tracer: tracer });

console.log("PARSED:");
console.log(JSON.stringify(parsed, null, 2));
