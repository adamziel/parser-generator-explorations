use test_parser::FunctionDef;
use peginator::PegParser;
mod test_parser;


fn main() {
    let input = "fn example(&self, input:&str, rectified:&mut Rect, rectified2:&mut Rect, rectified3:&mut Rect) -> ExampleResult;";
    let result = FunctionDef::parse(input);
    // Do something with the result
    println!("{:#?}", result);
}