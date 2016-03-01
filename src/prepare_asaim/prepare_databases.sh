#!/bin/bash
. src/misc.sh

source $galaxy_dir/.venv/bin/activate

current_dir=$PWD

gi_url="http://"$host":"$port

echo "Prepare SortMeRNA databases..."
declare RESULT=($(python $src_prepare/get_installed_tool_info.py \
    --tool_name "sortmerna" \
    --tool_shed "testtoolshed.g2.bx.psu.edu" \
    --gi_url $gi_url \
    --api_key $master_api_key))
revision=${RESULT[0]}
owner=${RESULT[1]}
sortmerna_db_dir=$galaxy_dir/dependency_dir/sortmerna/2.0/$owner/sortmerna/$revision/rRNA_databases/

cd $sortmerna_db_dir
if [[ ! -f rfam-5.8s-database-id98.stats ]]; then
    echo "  rfam-5.8s-database-id98"
    ../bin/indexdb_rna --ref rfam-5.8s-database-id98.fasta,rfam-5.8s-database-id98
fi
if [[ ! -f rfam-5s-database-id98.stats ]]; then
    echo "  rfam-5s-database-id98"
    ../bin/indexdb_rna --ref rfam-5s-database-id98.fasta,rfam-5s-database-id98
fi
if [[ ! -f silva-arc-16s-id95.stats ]]; then
    echo "  silva-arc-16s-id95"
    ../bin/indexdb_rna --ref silva-arc-16s-id95.fasta,silva-arc-16s-id95
fi
if [[ ! -f silva-arc-23s-id98.stats ]]; then
    echo "  silva-arc-23s-id98"
    ../bin/indexdb_rna --ref silva-arc-23s-id98.fasta,silva-arc-23s-id98
fi
if [[ ! -f silva-bac-16s-id90.stats ]]; then
    echo "  silva-bac-16s-id90"
    ../bin/indexdb_rna --ref silva-bac-16s-id90.fasta,silva-bac-16s-id90
fi
if [[ ! -f silva-bac-23s-id98.stats ]]; then
    echo "  silva-bac-23s-id98"
    ../bin/indexdb_rna --ref silva-bac-23s-id98.fasta,silva-bac-23s-id98
fi
if [[ ! -f silva-euk-18s-id95.stats ]]; then
    echo "  silva-euk-18s-id95"
    ../bin/indexdb_rna --ref silva-euk-18s-id95.fasta,silva-euk-18s-id95
fi
if [[ ! -f silva-euk-28s-id98.stats ]]; then
    echo "  silva-euk-28s-id98"
    ../bin/indexdb_rna --ref silva-euk-28s-id98.fasta,silva-euk-28s-id98
fi
cd $current_dir
echo ""

echo "Prepare HUMAnN2 databases..."
declare RESULT=($(python $src_prepare/get_installed_tool_info.py \
    --tool_name "package_humann_2_0" \
    --tool_shed "testtoolshed.g2.bx.psu.edu" \
    --gi_url $gi_url \
    --api_key $master_api_key))
revision=${RESULT[0]}
owner=${RESULT[1]}
humann2_db_dir=$galaxy_dir/dependency_dir/humann2/2.0/$owner/package_humann_2_0/$revision/

cd $humann2_db_dir
if [ ! -d "databases/chocophlan" ]; then
    ./humann2_databases --download chocophlan full databases/
fi
if [ ! -d "databases/uniref" ]; then
    ./humann2_databases --download uniref diamond databases/
fi
cd $current_dir
echo ""

## retrieve Greengenes for QIIME
echo "Prepare QIIME databases..."
declare RESULT=($(python $src_prepare/get_installed_tool_info.py \
    --tool_name "qiime" \
    --gi_url $gi_url \
    --api_key $master_api_key))
revision=${RESULT[0]}
owner=${RESULT[1]}
qiime_dir=$galaxy_dir/dependency_dir/qiime/1.9.1/$owner/qiime/$revision
cd $qiime_dir

if [ ! -d "databases" ]; then
    mkdir "databases"
fi
cd "databases"

echo "  Greengenes downloading, extracting and formating..."
wget ftp://greengenes.microbio.me/greengenes_release/gg_13_5/gg_13_8_otus.tar.gz
tar xzf gg_13_8_otus.tar.gz
rm gg_13_8_otus.tar.gz

echo "  SILVA downloading, extracting and formating..."
db_version="119"
silva_db_name="Silva_"$db_version
wget "http://www.arb-silva.de/fileadmin/silva_databases/qiime/"$silva_db_name"_release_aligned_rep_files.tar.gz"
tar xzf $silva_db_name"_release_aligned_rep_files.tar.gz"
rm $silva_db_name"_release_aligned_rep_files.tar.gz"

function gunzip_and_move {
    gunzip "Silva"$db_version"_release_aligned_rep_files/$1/"$silva_db_name"_"$2".fna.gz"
    mv "Silva"$db_version"_release_aligned_rep_files/$1/"$silva_db_name"_"$2".fna" .
}

gunzip_and_move "90" "rep_set90_aligned"
gunzip_and_move "90_16S_only" "rep_set90_aligned_16S_only"
gunzip_and_move "90_18S_only" "rep_set90_aligned_18S_only"
gunzip_and_move "94" "rep_set94_aligned"
gunzip_and_move "94_16S_only" "rep_set94_aligned_16S_only"
gunzip_and_move "94_18S_only" "rep_set94_aligned_18S_only"
gunzip_and_move "97" "rep_set97_aligned"
gunzip_and_move "97_16S_only" "rep_set97_aligned_16S_only"
gunzip_and_move "97_18S_only" "rep_set97_aligned_18S_only"
gunzip_and_move "99" "rep_set99_aligned"
gunzip_and_move "99_16S_only" "rep_set99_aligned_16S_only"
gunzip_and_move "99_18S_only" "rep_set99_aligned_18S_only"

rm -rf "Silva"$db_version"release_aligned_rep_files"
