
BEGIN {

    s = "echo \"Hello\"\n" \
         "echo 'World   tab space'\n"  \
         "echo $((2+5))\n" \
         "echo `whoami`\n" \
         "echo \"aaa\n\t\tbbb\""

    print "-----"
    print s
    print "====="

    # script = "define(){ while IFS= read -r l; do VAR=\"$VAR$l\"'\n'; i=$((i+1)); echo \"iter $i\"; done; }\n" \
    script = "{ while IFS= read -r l; do VAR=\"$VAR$l\"'\n'; done; } <<'EOF'\n" \
                        s \
                        "\nEOF\n" \
                        "echo \"$VAR\"; bash -c \"$VAR\"; echo $?"
    print script

    print "=== RESULT ==="
    system(script)

    #system("IFS='\034' read -r VAR <<'END'\n" s "\034\nEND\necho \"$VAR\"")
    #system("IFS=\"\\t\" read -r VAR <<'END'\n" s "\t\nEND\necho \"$VAR\"")
}