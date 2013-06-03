<?php defined('SYSPATH') or die('No direct script access.');

class <+call:substitute(matchstr(expand('%:p'),'classes/\zs.*\ze.php'),'/','_','g')+> extends <+call:expand('%:p:h:t')+> {

	<+CURSOR+>

}
