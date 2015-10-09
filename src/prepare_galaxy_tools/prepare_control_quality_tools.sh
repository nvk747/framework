#!/bin/bash

. ./src/prepare_galaxy_tools/functions.sh 

galaxy_tool_dir=$1
tool_dir=$2
current_dir=`pwd`

section_dir=control_quality

echo "Control quality..."
create_tool_section_dir $galaxy_tool_dir/$section_dir

## prinseq
echo " PRINSEQ..."
prinseq_dir=$section_dir/prinseq
create_copy_tool_dir $tool_dir/$prinseq_dir $galaxy_tool_dir/$prinseq_dir
mkdir -p $galaxy_tool_dir/$prinseq_dir/src/
curl -L -s http://downloads.sourceforge.net/project/prinseq/standalone/prinseq-lite-0.20.4.tar.gz | tar -C $galaxy_tool_dir/$prinseq_dir/src/ --strip-components=1 -xz