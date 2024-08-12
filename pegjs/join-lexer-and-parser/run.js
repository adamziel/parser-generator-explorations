// const l = require('./peggy_lexer.js');
// console.log(l.parse('SELECT 1'));

// try {
//     const peg = require('./peg_parser.js');
//     console.log(peg.parse('SELECT 1;'));
// } catch (e) {
//     console.error(e.message);
// }

try {
    const peggy = require('./peggy_parser.js');
    // console.log(
        JSON.stringify(peggy.parse('SELECT 12 FROM my_table'), null, 2)
    // );
} catch (e) {
    console.error(e.message);
}
