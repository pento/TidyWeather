<?php

$primitivesData = simplexml_load_file( 'icons/primitives.svg' );

$primitives = [];
foreach( $primitivesData->children() as $child ) {
	$primitives[ (string)$child->attributes()[ 'id' ] ] = $child;
}

foreach( glob( 'icons/weather*' ) as $iconFile ) {
	echo "$iconFile\n";
	$iconData = simplexml_load_file( $iconFile, 'MySimpleXMLElement' );
	$iconData->registerXPathNamespace( 'svg', 'http://www.w3.org/2000/svg' );
	$iconData->registerXPathNamespace( 'xlink', 'http://www.w3.org/1999/xlink' );

	foreach( $iconData->xpath( '//svg:use' ) as $embed ) {
		$href = (string)$embed->attributes( 'xlink', true )[ 'href' ];

		[ $filename, $id ] = explode( '#', $href );
		if( $filename === 'primitives.svg' ) {
			$embed->replace( $primitives[ $id ] );
		} elseif ( ! empty( $filename ) && file_exists( "icons/generated/$filename" ) ) {
			$embedData = simplexml_load_file( "icons/generated/$filename" );
			$embed->replace( $embedData->xpath( "//*[@id='$id']" )[0] );
		}
	}

	$generatedFile = str_replace( 'icons/', 'icons/generated/', $iconFile );
	$iconData->asXML( $generatedFile );
}

/**
 * Class MySimpleXMLElement
 */
class MySimpleXMLElement extends SimpleXMLElement {
    /**
     * @param SimpleXMLElement $element
     */
    public function replace( SimpleXMLElement $element ) {
		$dom = dom_import_simplexml( $this );

		$wrapper = $dom->ownerDocument->createElement( 'g' );
		$wrapper->setAttribute( 'transform', (string)$this->attributes()[ 'transform' ] );
		$wrapper->setAttribute( 'style', (string)$this->attributes()[ 'style' ] );

		$import = $dom->ownerDocument->importNode( dom_import_simplexml( $element ), true );
		$wrapper->appendChild( $import );

		$dom->parentNode->replaceChild( $wrapper, $dom );
    }
}
