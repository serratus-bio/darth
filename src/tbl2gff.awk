#!/usr/bin/awk -f

## Call with -v seqid="seq_id" -v prog="vadr"

BEGIN {
    FS = OFS = "\t"
    print "##gff-version 3"
}

## We've reached the end of the annotations, so quit:
/^$/ { exit }
/^>/ { next }

$1 && $2 && "ID" in annot {

    attributes = ""
    ## Concatenate the annots:
    for (field in annot) {
	attributes = attributes field "=" annot[field] ";"
    }
    
    ## Print the GFF3 line:
    print seqid,
	prog,
	(ftr_key!="")?ftr_key:"biological_feature",
	start,
	end,
	".",
	strand,
	".",
	attributes

    ## Clear the array:
    delete annot
    split("",annot,"")
}

$1 && $2 {
    if ( $1 < $2 ) {
	start  = $1
	end    = $2
	strand = "+"
    } else {
	start  = $2
	end    = $1
	strand = "-"
    } 
    ftr_key = $3
    ++ftr_id
    #print start, end, strand, ftr_key, ftr_id
}

!$1 && !$2 {
    qual_key   = $4
    qual_value = $5

    annot["ID"] = "feature" ftr_id
    
    if (qual_key == "gene")
	annot["Name"] = qual_value
    if (qual_key == "note")
	annot["Note"] = qual_value
    if (qual_key == "protein_id")
	annot["Alias"] = qual_value
    if (qual_key == "product")
	annot["Note"] = qual_value
}

END {

    attributes = ""
    ## Concatenate the annots:
    for (field in annot) {
	attributes = attributes field "=" annot[field] ";"
    }
    
    ## Print the GFF3 line:
    print seqid,
	prog,
	(ftr_key!="")?ftr_key:"biological_feature",
	start,
	end,
	".",
	strand,
	".",
	attributes

}
