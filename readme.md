
SwiftVisualizer is a small jq script that converts sourcekitten docs to .dot
files.

usage:

```
   sourcekitten doc -- -project <project> -scheme <scheme> > doc.json
   cat doc.json | jq -f -r parser.jq > graph.dot
   dot -Tpng graph.dot -o graph.png
```
