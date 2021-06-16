# pandoc-notion-subpages-filter

Assemble Notion.so Export subpages into a single document with this Pandoc filter.

It is highly inspired by pandoc's [`include-files`](https://github.com/pandoc/lua-filters/blob/master/include-files/include-files.lua).


# Usage

```bash
$  pandoc --lua-filter=/…/pandoc-notion-subpages-filter/notion-subpages.lua -t markdown notion-export.md
```
