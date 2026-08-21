# git-commit-fmt.awk - reflow a git commit message body without breaking it.
#
#   awk -v width=72 -f git-commit-fmt.awk < COMMIT_EDITMSG
#
# Only prose paragraphs and list items are rewrapped. Everything that has to
# survive byte-for-byte does:
#
#   * the subject line, and the blank line separating it from the body
#   * git's own '#' comments
#   * everything from the '>8' scissors line (or a 'diff --git' header) down,
#     so `git commit -v` diffs stay intact
#   * fenced code blocks, indented blocks, blockquotes
#   * trailer paragraphs (Signed-off-by:, Co-authored-by:, bare URLs, ...)
#
# Wrapping is greedy and never splits a word, so long URLs overflow the margin
# rather than becoming unclickable.

function blank_of(s,   t) {
    # Same width as s, but blank - keeps tabs, turns everything else to spaces.
    t = s
    gsub(/[^\t]/, " ", t)
    return t
}

function is_trailer(s) {
    return s ~ /^[A-Za-z][A-Za-z0-9-]*:[ \t]*[^ \t]/
}

# Emit the pending paragraph, wrapped, and reset the buffer.
function flush(   i, txt, out, words, n, j) {
    if (nbuf == 0)
        return

    # A paragraph whose every line reads as "Key: value" is a trailer block.
    # Joining those lines would corrupt them, so pass it through untouched.
    if (!islist) {
        for (i = 1; i <= nbuf; i++)
            if (!is_trailer(buf[i]))
                break
        if (i > nbuf) {
            for (i = 1; i <= nbuf; i++)
                print buf[i]
            nbuf = 0
            return
        }
    }

    txt = buf[1]
    for (i = 2; i <= nbuf; i++)
        txt = txt " " buf[i]
    gsub(/[ \t]+/, " ", txt)
    sub(/^ /, "", txt)
    sub(/ $/, "", txt)
    nbuf = 0
    if (txt == "")
        return

    n = split(txt, words, " ")
    out = pfx1 words[1]
    for (j = 2; j <= n; j++) {
        if (length(out) + 1 + length(words[j]) <= width)
            out = out " " words[j]
        else {
            print out
            out = pfxc words[j]
        }
    }
    print out
}

# Start a new paragraph that continues at the same indent as it starts.
function open_plain(l) {
    match(l, /^[ \t]*/)
    pfx1 = pfxc = substr(l, 1, RLENGTH)
    islist = 0
}

BEGIN {
    if (width + 0 <= 0)
        width = 72
}

# Past the scissors, nothing below is ours to touch - not even trailing space.
verbatim { print; next }
/^#[ \t]*-+[ \t]*>8[ \t]*-+/ || /^diff --git / {
    flush()
    verbatim = 1
    print
    next
}

{ line = $0; sub(/[ \t]+$/, "", line) }

# The subject is never wrapped: git wants it on one line.
NR == 1 { subject = line; print line; next }

# Body without a blank line after the subject? Insert one, then keep going.
NR == 2 && subject != "" && line != "" && line !~ /^#/ { print "" }

line ~ /^(```|~~~)/ { flush(); fenced = !fenced; print line; next }
fenced                { print line; next }

line ~ /^#/           { flush(); print line; next }
line == ""            { flush(); print ""; next }

# Indented blocks and blockquotes are quoted material - leave them alone.
line ~ /^( {4,}|\t)/  { flush(); print line; next }
line ~ /^[ \t]*>/     { flush(); print line; next }

# A list marker always begins a new item; continuation lines hang under it.
match(line, /^[ \t]*([-*+]|[0-9]+[.)])[ \t]+/) {
    flush()
    pfx1 = substr(line, 1, RLENGTH)
    pfxc = blank_of(pfx1)
    islist = 1
    buf[++nbuf] = substr(line, RLENGTH + 1)
    next
}

{
    if (nbuf == 0)
        open_plain(line)
    buf[++nbuf] = line
}

END { flush() }
