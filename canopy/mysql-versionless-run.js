const json = require('./mysql-versionless')

let tree = json.parse('SELECT`a`FROM;')
console.log(JSON.stringify(tree, null, 2));
// for (let node of tree) {
//     console.log({ node });
// //   console.log(node.offset, node.text)
// }