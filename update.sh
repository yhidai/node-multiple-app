d=`date +"%Y-%m-%d_%H:%m:%S"` && echo ${d} > work/text.txt && git add -A && git commit -m "${d}" && git push
