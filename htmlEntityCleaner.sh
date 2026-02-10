# Convertit &lt; &gt; en < >
sed -i 's/&lt;/</g; s/&gt;/>/g' src/tools/**/*.zig

# Normalise CRLF -> LF
find src -name '*.zig' -print0 | xargs -0 sed -i 's/\r$//'


# Nettoie toutes les entités HTML les plus courantes
sed -i 's/&lt;/</g; s/&gt;/>/g; s/&amp;/\&/g' vendor/tree-sitter-heaven/grammar.js
sed -i 's/&lt;/</g; s/&gt;/>/g; s/&amp;/\&/g' vendor/tree-sitter-heaven/queries/*.scm


# Vérifie s'il reste des entités HTML
grep -R --line-number -E '&lt;|&gt;|&amp;' vendor/tree-sitter-heaven || true

# Vérifie les occurrences de la flèche '->' dans grammar.js
grep -n "\->" vendor/tree-sitter-heaven/grammar.js || true

# Vérifie les backslashes dans la règle lambda (recherche approximative)
grep -n "seq('\\\\'," vendor/tree-sitter-heaven/grammar.js || true


# 1) remplacer &amp; -> &
find src -type f -print0 | xargs -0 sed -i '' 's/&amp;/\&/g'

# 2) remplacer &lt; -> <
find src -type f -print0 | xargs -0 sed -i '' 's/&lt;/</g'

# 3) remplacer &gt; -> >
find src -type f -print0 | xargs -0 sed -i '' 's/&gt;/>/g'

