const json = require('./json-runnable')

let tree = json.parse('[1, {"a": "b"}, ["d"], 2,3]')
console.log(tree.val());
// for (let node of tree) {
//     console.log({ node });
// //   console.log(node.offset, node.text)
// }