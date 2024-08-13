use mysql_parser::query;
use mysql_parser::querySpecification;
use peginator::PegParser;
use peginator::PegParserAdvanced;
mod mysql_parser;

fn main() {
    // let input = "ALTER TABLE `table` ADD COLUMN `column` INT";
    // let result = query::parse(input);
    let input = "SELECT 1, 2 FROM `my_table` WHERE `my_column` = 3";
    let result = querySpecification::parse(input);
    // Do something with the result
    println!("{:#?}", result);
}
