mmseg -u uni.txt
python build_thesaurus.py uni.txt > thesaurus.txt
mmseg -t thesaurus.txt
mv uni.txt.uni uni.lib
