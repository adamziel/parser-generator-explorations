<?php

require_once dirname(__DIR__).'/autoloader.php';
use hafriedlander\Peg\Parser;

class MathAST extends Parser\Basic {

/*!* MathAST

Number: /[0-9]+/
Value: Number > | '(' > Expr > ')' >
	function Number( &$result, $sub ) {
		$result['val'] = $sub;
	}
	function Expr( &$result, $sub ) {
		$result['val'] = $sub;
	}

Times: '*' > operand:Value >
	function Times( &$result, $sub ) {
		$result['val'] = $sub;
	}
Div: '/' > operand:Value >
	function Div( &$result, $sub ) {
		$result['val'] = $sub;
	}
Product: Value > ( Times | Div ) *
	function Value( &$result, $sub ) {
		$result['val'] = $sub;
	}


Plus: '+' > operand:Product >
	function Plus( &$result, $sub ) {
		$result['val'] = $sub;
	}
Minus: '-' > operand:Product >
	function Minus( &$result, $sub ) {
		$result['val'] = $sub;
	}
Sum: Product > ( Plus | Minus ) *
	function Product( &$result, $sub ) {
		$result['val'] = $sub;
	}

Expr: Sum
	function Sum( &$result, $sub ) {
		$result['val'] = $sub;
	}

*/

}

$x = new MathAST( '2 + 4 * 3 - 10' ) ;
$res = $x->match_Expr() ;
if ( $res === FALSE ) {
	print "No Match\n" ;
}
else {
	print_r( $res ) ;
}



