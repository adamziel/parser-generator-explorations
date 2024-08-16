

// // Helper function to update the match array (similar to Python's implementation)
    // private function update_match(&$match, $subrule_name, $matched_children) {
    //     while (is_array($matched_children) && count($matched_children) === 1) {
    //         $matched_children = $matched_children[0];
    //     }
    //     if (strpos($subrule_name, '%') !== 0) {
    //         $match[$subrule_name][] = $matched_children;
    //         return;
    //     }
    //     if (is_array($matched_children) && isset($matched_children[0]) && is_array($matched_children[0])) {
    //         foreach ($matched_children as $item) {
    //             foreach ($item as $key => $value) {
    //                 if (is_array($value)) {
    //                     $this->_safe_extend_dict($match, $value);
    //                 } else {
    //                     $match[$key][] = $value;
    //                 }
    //             }
    //         }
    //     } else {
    //         $match[$subrule_name][] = $matched_children;
    //     }
    // }

    // // Helper function to safely extend a dictionary (similar to Python's implementation)
    // private function _safe_extend_dict(&$base_dict, $dict2) {
    //     foreach ($dict2 as $key => $value) {
    //         if (isset($base_dict[$key])) {
    //             if (!is_array($base_dict[$key])) {
    //                 $base_dict[$key] = [$base_dict[$key]];
    //             }
    //             $base_dict[$key][] = $value;
    //         } else {
    //             $base_dict[$key] = $value;
    //         }
    //     }
    //     return $base_dict;
    // }