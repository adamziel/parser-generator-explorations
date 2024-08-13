import { parser } from "./snowsql";

const program = `WITH mytable AS (select 1 as a, \`b\`.c from dual)
SELECT HIGH_PRIORITY DISTINCT
	CONCAT("a", "b"),
	UPPER(z),
    DATE_FORMAT(col_a, '%Y-%m-%d %H:%i:%s') as formatted_date,
    DATE_ADD(col_b, INTERVAL 1 DAY) as date_plus_one,
	col_a
FROM 
(SELECT \`mycol\`, 997482686 FROM "mytable") as subquery
LEFT JOIN (SELECT a_column_yo from mytable) as t2 
    ON (t2.id = mytable.id AND t2.id = 1)
WHERE 1 = 3
GROUP BY col_a, col_b
HAVING 1 = 2
UNION SELECT * from table_cde
ORDER BY col_a DESC, col_b ASC
FOR UPDATE`;

function getContent(node, input=program) {
  return input.slice(node.from, node.to)
}
console.time('parse');
for (let i = 0; i < 500; i++) {
  const tree = parser.parse(program)
  // console.log(tree.toString());
  let cursor = tree.cursor()
  do {
    // console.log(`Node ${cursor.name} from ${cursor.from} to ${cursor.to}`)
    // console.log(getContent(cursor.node));
  } while (cursor.next())
}
console.timeEnd('parse');