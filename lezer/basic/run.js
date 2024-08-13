import { parser } from "./basic";

const program = `a "bcd" ('d' 'e')`
function getContent(node, input=program) {
  return input.slice(node.from, node.to)
}
const tree = parser.parse(program)
let cursor = tree.cursor()
do {
  console.log(`Node ${cursor.name} from ${cursor.from} to ${cursor.to}`)
  console.log(getContent(cursor.node));
} while (cursor.next())