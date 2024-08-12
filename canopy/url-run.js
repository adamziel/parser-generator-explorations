const url = require('./url')

let tree = url.parse('http://example.com/search?q=hello#page=1')

for (let node of tree) {
    console.log({ node });
//   console.log(node.offset, node.text)
}