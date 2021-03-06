function __fish_quilt_is_quiltdir -d "Return true if there is a quilt series file somewhere in the path"
    set -l currentdir "$argv[1]"
    if test -z "$currentdir"
        set currentdir "$PWD"
    end
    set -l patchdir "patches"
    set -l seriesfile "series"
    if test -n "$QUILT_PATCHES"
        set patchdir "$QUILT_PATCHES"
    end
    if test -n "$QUILT_SERIES"
        set seriesfile "$QUILT_SERIES"
    end
    if test -e "$currentdir/$patchdir/$seriesfile"
        return 0
    else
        if test "$currentdir" = "/"
            return 1
        else
            __fish_quilt_is_quiltdir (dirname $currentdir)
        end
    end
end

function __fish_quilt_set_color -d "Initialize variable with a default value"
    set -l user_variable_name "$argv[1]"
    set -l default $argv[2]
    set -l user_variable $$user_variable_name

    if not set -q $user_variable_name
        set -g $user_variable_name (set -q $user_variable_name; and echo $user_variable; or echo $default)
        set -g "$user_variable_name"_done (set_color normal)
    end
end

function __fish_quilt_prompt -d "Write out the quilt prompt"
    if not command -sq quilt
        return 1
    end
    if not __fish_quilt_is_quiltdir
        return 1
    end
    set -l patches
    command quilt series ^/dev/null | while read p
        set patches $patches $p
    end
    set -l npatches (count $patches)
    set -l current_patch (command quilt top ^/dev/null)
    set -l idx_patch "0"
    if test -n "$current_patch"
        set idx_patch (contains -i $current_patch $patches)
        set current_patch (basename $current_patch)
    else
        set current_patch "No patches applied"
    end
    __fish_quilt_set_color __fish_quilt_prompt_color (set_color blue)
    set -l format $argv[1]
    if test -z "$format"
        set format " (%s)"
    end
    set prompt "$__fish_quilt_prompt_color$current_patch $idx_patch/$npatches$__fish_quilt_prompt_color_done"
    printf $format $prompt
end
