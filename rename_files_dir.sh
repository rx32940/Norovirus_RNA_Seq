#!/bin/bash
input="/scicomp/home-pure/rwo8/workdir/rna_seq_oxy_bile_data_combined/info"
salmon="/scicomp/home-pure/rwo8/workdir/rna_seq_oxy_bile_data_combined/salmon"

while read -r old_name new_name;
do

# echo $new_name
mv --strip-trailing-slashes -n "$salmon/$old_name" "$salmon/$new_name"

done < "$input/dataset2_names_dict.tsv"