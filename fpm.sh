#!/bin/bash

# Package Manager Commands
# pacman
info_pacman="pacman -Si"
install_pacman="sudo pacman -S"
remove_pacman="sudo pacman -R"
upgrade_pacman="sudo pacman -S"
search_available_pacman="pacman -Ss"
search_installed_pacman="pacman -Q"
autoclean_pacman="sudo pacman -Qdtq | sudo pacman -Rns -"
clean_pacman="sudo pacman -Sc"
update_pacman="sudo pacman -Syu"
add_repo_pacman="echo 'Add to /etc/pacman.conf: [$repo]' && echo 'Then run: sudo pacman -Sy'"

# apt
info_apt="apt show"
install_apt="sudo apt install"
remove_apt="sudo apt remove"
upgrade_apt="sudo apt install --only-upgrade"
search_available_apt="apt search"
search_installed_apt="dpkg -l"
autoclean_apt="sudo apt autoremove"
clean_apt="sudo apt clean"
update_apt="sudo apt update && sudo apt upgrade"
add_repo_apt="sudo add-apt-repository"

# dnf
info_dnf="dnf info"
install_dnf="sudo dnf install"
remove_dnf="sudo dnf remove"
upgrade_dnf="sudo dnf upgrade"
search_available_dnf="dnf search"
search_installed_dnf="dnf list installed"
autoclean_dnf="sudo dnf autoremove"
clean_dnf="sudo dnf clean all"
update_dnf="sudo dnf upgrade"
add_repo_dnf="sudo dnf config-manager --add-repo"

# xbps
info_xbps="xbps-query -S"
install_xbps="sudo xbps-install"
remove_xbps="sudo xbps-remove"
upgrade_xbps="sudo xbps-install -u"
search_available_xbps="xbps-query -Rs"
search_installed_xbps="xbps-query -l"
autoclean_xbps="sudo xbps-remove -O"
clean_xbps="sudo xbps-remove -o"
update_xbps="sudo xbps-install -Su"
add_repo_xbps="echo 'Add to /etc/xbps.d/ or use xbps-src'"

# nix
info_nix="nix-env -qa --description"
install_nix="nix-env -i"
remove_nix="nix-env -e"
upgrade_nix="nix-env -u"
search_available_nix="nix-env -qa"
search_installed_nix="nix-env -q"
autoclean_nix="echo 'Nix handles garbage collection: nix-collect-garbage'"
clean_nix="nix-collect-garbage"
update_nix="nix-channel --update && nix-env -u"
add_repo_nix="echo 'Add channels with nix-channel --add'"

p() {
    if command -v pacman >/dev/null 2>&1; then
        echo "pacman"
    elif command -v apt >/dev/null 2>&1; then
        echo "apt"
    elif command -v dnf >/dev/null 2>&1; then
        echo "dnf"
    elif command -v xbps >/dev/null 2>&1; then
        echo "xbps"
    elif command -v nix >/dev/null 2>&1; then
        echo "nix"
    else
        echo "unknown"
    fi
}

gg() {
    local pkg="$1"
    case $PM in
        pacman)
            pacman -Si "$pkg" 2>/dev/null | grep '^Groups' | cut -d: -f2 | tr -d ' ' | tr ',' ' ' | head -1 || echo ""
            ;;
        apt)
            apt show "$pkg" 2>/dev/null | grep '^Section' | cut -d: -f2 | tr -d ' ' || echo ""
            ;;
        dnf)
            dnf info "$pkg" 2>/dev/null | grep '^Group' | cut -d: -f2 | tr -d ' ' || echo ""
            ;;
        *)
            echo ""
            ;;
    esac
}

ii() {
    local pkg="$1"
    case $PM in
        pacman)
            pacman -Q "$pkg" >/dev/null 2>&1 && echo "Yes" || echo "No"
            ;;
        apt)
            dpkg -l "$pkg" 2>/dev/null | grep -q "^ii" && echo "Yes" || echo "No"
            ;;
        dnf)
            dnf list installed "$pkg" >/dev/null 2>&1 && echo "Yes" || echo "No"
            ;;
        *)
            echo "No"
            ;;
    esac
}

sp() {
    local q="$1"
    local l="${2:-20}"
    local si="${3:-false}"
    local r
    if $si; then
        case $PM in
            pacman)
                r=$(eval "$search_installed_pacman" 2>/dev/null | grep "$q" | grep -v '^lib' | head -"$l")
                ;;
            apt)
                r=$(eval "$search_installed_apt" 2>/dev/null | grep "^ii" | awk '{print $2}' | grep "$q" | grep -v '^lib' | head -"$l")
                ;;
            dnf)
                r=$(eval "$search_installed_dnf" 2>/dev/null | grep "$q" | awk '{print $1}' | grep -v '^lib' | head -"$l")
                ;;
            xbps)
                r=$(eval "$search_installed_xbps" 2>/dev/null | grep "$q" | grep -v '^lib' | head -"$l")
                ;;
            nix)
                r=$(eval "$search_installed_nix" 2>/dev/null | grep "$q" | head -"$l")
                ;;
            *)
                echo "Unsupported package manager"
                return 1
                ;;
        esac
    else
        case $PM in
            pacman)
                r=$(eval "$search_available_pacman '$q'" 2>/dev/null | grep '/' | grep -v '^lib' | awk '{print $1}' | cut -d/ -f1 | head -"$l")
                ;;
            apt)
                r=$(eval "$search_available_apt '$q'" 2>/dev/null | grep '/' | grep -v '^lib' | awk '{print $1}' | cut -d/ -f1 | head -"$l")
                ;;
            dnf)
                r=$(eval "$search_available_dnf '$q'" 2>/dev/null | grep '/' | grep -v '^lib' | awk '{print $1}' | cut -d/ -f1 | head -"$l")
                ;;
            xbps)
                r=$(eval "$search_available_xbps '$q'" 2>/dev/null | grep "$q" | head -"$l")
                ;;
            nix)
                r=$(eval "$search_available_nix '$q'" 2>/dev/null | grep "$q" | head -"$l")
                ;;
            *)
                echo "Unsupported package manager"
                return 1
                ;;
        esac
    fi
    echo "$r"
}

srt() {
    local q="$1"
    shift
    local pk=("$@")
    local scd=()
    for pkg in "${pk[@]}"; do
        if [[ "$pkg" == "$q"* ]]; then
            sc=3
        elif [[ "$pkg" == *"$q"* ]]; then
            sc=2
        else
            sc=1
        fi
        scd+=("$sc $pkg")
    done
    printf '%s\n' "${scd[@]}" | sort -k1,1nr -k2,2 | cut -d' ' -f2-
}

sd() {
    local pkg="$1"
    if $dry_run; then
        echo "Would show info for $pkg"
    else
        eval "$info_$PM '$pkg'" 2>/dev/null
    fi
}

ip() {
    local pkg="$1"
    if [[ ! "$pkg" =~ ^[a-zA-Z0-9._-]+$ ]]; then
        echo "Invalid package name: $pkg"
        return 1
    fi
    if $dry_run; then
        echo "Would run: $install_$PM '$pkg'"
    else
        eval "$install_$PM '$pkg'"
        if [ $? -ne 0 ]; then
            echo "Install failed for $pkg"
        fi
    fi
}

rp() {
    local pkg="$1"
    if [[ ! "$pkg" =~ ^[a-zA-Z0-9._-]+$ ]]; then
        echo "Invalid package name: $pkg"
        return 1
    fi
    if $dry_run; then
        echo "Would run: $remove_$PM '$pkg'"
    else
        eval "$remove_$PM '$pkg'"
        if [ $? -ne 0 ]; then
            echo "Remove failed for $pkg"
        fi
    fi
}

up() {
    local pkg="$1"
    if [[ ! "$pkg" =~ ^[a-zA-Z0-9._-]+$ ]]; then
        echo "Invalid package name: $pkg"
        return 1
    fi
    if $dry_run; then
        echo "Would run: $upgrade_$PM '$pkg'"
    else
        eval "$upgrade_$PM '$pkg'"
        if [ $? -ne 0 ]; then
            echo "Upgrade failed for $pkg"
        fi
    fi
}

ar() {
    local repo="$1"
    if $dry_run; then
        echo "Would run: $add_repo_$PM '$repo'"
    else
        eval "$add_repo_$PM '$repo'"
    fi
}

acp() {
    if $dry_run; then
        echo "Would run: $autoclean_$PM"
    else
        eval "$autoclean_$PM"
    fi
}

cc() {
    if $dry_run; then
        echo "Would run: $clean_$PM"
    else
        eval "$clean_$PM"
    fi
}

us() {
    if $dry_run; then
        echo "Would run: $update_$PM"
    else
        eval "$update_$PM"
    fi
}

dt() {
    local pk=("$@")
    if [ ${#pk[@]} -eq 0 ]; then
        echo "No packages found."
        return
    fi
    if $sg && $ss; then
        echo "No. | Group      | Installed | Package Name"
        echo "----|------------|-----------|-------------"
        for idx in "${!pk[@]}"; do
            g=$(gg "${pk[idx]}")
            inst=$(ii "${pk[idx]}")
            printf "%2d | %-10s | %-9s | %s\n" $((idx+1)) "$g" "$inst" "${pk[idx]}"
        done
    elif $sg; then
        echo "No. | Group      | Package Name"
        echo "----|------------|-------------"
        for idx in "${!pk[@]}"; do
            g=$(gg "${pk[idx]}")
            printf "%2d | %-10s | %s\n" $((idx+1)) "$g" "${pk[idx]}"
        done
    elif $ss; then
        echo "No. | Installed | Package Name"
        echo "----|-----------|-------------"
        for idx in "${!pk[@]}"; do
            inst=$(ii "${pk[idx]}")
            printf "%2d | %-9s | %s\n" $((idx+1)) "$inst" "${pk[idx]}"
        done
    else
        echo "No. | Package Name"
        echo "----|-------------"
        for idx in "${!pk[@]}"; do
            printf "%2d | %s\n" $((idx+1)) "${pk[idx]}"
        done
    fi
    echo ""
    echo "Total packages found: ${#pk[@]}"
}

PM=$(p)
if [ "$PM" = "unknown" ]; then
echo "No supported package manager found."
exit 1
fi
c="$HOME/.fpm_config"
l=20
m="list"
sd=true
dry_run=false
if [ -f "$c" ]; then
while IFS='=' read -r key value; do
case $key in
limit) l="$value" ;;
mode) m="$value" ;;
show_details) sd="$value" ;;
esac
done < "$c"
fi
ul=false
um=false
toggle_sd=false
si=false
ac=false
cc=false
us=false
sg=false
ss=false
lq=""
ip=""
rp=false
up=false
ar=false
rp_pkg=""
up_pkg=""
ar_repo=""
rp=false
up=false
ar=false
rp_pkg=""
up_pkg=""
ar_repo=""
while getopts "n:m:hisl:I:acgtuR:U:A:dD" opt; do
case $opt in
n) l="$OPTARG"; ul=true ;;
m) if [[ "$OPTARG" != "list" && "$OPTARG" != "install" ]]; then echo "Invalid mode: $OPTARG" >&2; exit 1; fi; m="$OPTARG"; um=true ;;
h) echo "Usage: $0 [-n limit] [-m mode] [-s] [-g] [-t] [-a] [-c] [-u] [-l <query> | -I <package> | -R <package> | -U <package> | -A <repo> | <query>]"
echo "  -n limit  Set number of packages to show (persists)"
echo "  -m mode   Set default mode: list or install (persists)"
echo "  -s        With -l or default list, show only installed packages"
echo "  -g        Show group/section column in list"
echo "  -t        Show installed status column in list"
echo "  -a        Autoclean unused packages"
echo "  -c        Clean package cache"
echo "  -u        Update system packages"
echo "  -d        Toggle show details on install/remove/upgrade (persists)"
echo "  -D        Dry-run mode (show commands without executing)"
echo "  -l query  List packages matching query"
echo "  -I pkg    Install package (shows details first)"
echo "  -R pkg    Remove package (shows details first)"
echo "  -U pkg    Upgrade specific package"
echo "  -A repo   Add repository"
echo "  -i        Show script info"
echo "  -h        Show this help"
exit 0 ;;
i) echo "FPM v0.6.8 - Advanced Linux Package Manager Wrapper"
echo "Made by Flasher | Efendi"
echo "See more info at https://github.com/flasherxgapple/fpm"
exit 0 ;;
s) si=true ;;
g) sg=true ;;
t) ss=true ;;
a) ac=true ;;
c) cc=true ;;
u) us=true ;;
l) lq="$OPTARG" ;;
I) ip="$OPTARG" ;;
R) rp_pkg="$OPTARG"; rp=true ;;
U) up_pkg="$OPTARG"; up=true ;;
A) ar_repo="$OPTARG"; ar=true ;;
d) toggle_sd=true ;;
D) dry_run=true ;;
*) echo "Usage: $0 [-n limit] [-m mode] [-s] [-g] [-t] [-a] [-c] [-u] [-d] [-D] [-l <query> | -I <package> | -R <package> | -U <package> | -A <repo> | <query>]" >&2; exit 1 ;;
esac
done
shift $((OPTIND-1))
if $ul || $um || $toggle_sd; then
{
echo "limit=$l"
echo "mode=$m"
echo "show_details=$sd"
} > "$c"
fi
if [ -n "$lq" ]; then
    q="$lq"
    r=$(sp "$q" "$l" "$si")
    IFS=$'\n' read -r -d '' -a pk <<< "$r"
    if ! $si; then
        sr=$(srt "$q" "${pk[@]}")
        IFS=$'\n' read -r -d '' -a pk <<< "$sr"
    fi
    ss=true
    dt "${pk[@]}"
    echo ""
    while true; do
        read -p "Enter package number to install, ?<number> for info, or blank to exit: " ch
        if [ -z "$ch" ]; then
            break
        fi
        if [[ "$ch" == \?* ]]; then
            n=${ch#?}
            if [[ "$n" =~ ^[0-9]+$ ]] && [ "$n" -gt 0 ] && [ "$n" -le ${#pk[@]} ]; then
                s="${pk[$((n-1))]}"
                echo "Details for $s:"
                sd "$s"
            else
                echo "Invalid number."
            fi
        elif [[ "$ch" =~ ^[0-9]+$ ]] && [ "$ch" -gt 0 ] && [ "$ch" -le ${#pk[@]} ]; then
            s="${pk[$((ch-1))]}"
            if $sd; then
                echo "Details for $s:"
                sd "$s"
            fi
            echo ""
            read -p "Install $s? (y/N): " cf
            if [[ $cf =~ ^[Yy]$ ]]; then
                ip "$s"
                break
            fi
        else
            echo "Invalid choice. Use number for install, ?number for info, or blank to exit."
        fi
    done
elif [ -n "$ip" ]; then
    if $sd; then
        echo "Details for $ip:"
        sd "$ip"
    fi
    read -p "Install $ip? (y/N): " cf
    if [[ $cf =~ ^[Yy]$ ]]; then
        ip "$ip"
    fi
elif $rp; then
    if $sd; then
        echo "Details for $rp_pkg:"
        sd "$rp_pkg"
    fi
    read -p "Remove $rp_pkg? (y/N): " cf
    if [[ $cf =~ ^[Yy]$ ]]; then
        rp "$rp_pkg"
    fi
elif $up; then
    if $sd; then
        echo "Details for $up_pkg:"
        sd "$up_pkg"
    fi
    read -p "Upgrade $up_pkg? (y/N): " cf
    if [[ $cf =~ ^[Yy]$ ]]; then
        up "$up_pkg"
    fi
elif $ar; then
    ar "$ar_repo"
elif [ $# -eq 1 ]; then
    q="$1"
    if [ "$m" = "list" ]; then
        r=$(sp "$q" "$l" "$si")
        IFS=$'\n' read -r -d '' -a pk <<< "$r"
        if ! $si; then
            sr=$(srt "$q" "${pk[@]}")
            IFS=$'\n' read -r -d '' -a pk <<< "$sr"
        fi
        ss=true
        dt "${pk[@]}"
        echo ""
        while true; do
            read -p "Enter package number to install, ?<number> for info, or blank to exit: " ch
            if [ -z "$ch" ]; then
                break
            fi
            if [[ "$ch" == \?* ]]; then
                n=${ch#?}
                if [[ "$n" =~ ^[0-9]+$ ]] && [ "$n" -gt 0 ] && [ "$n" -le ${#pk[@]} ]; then
                    s="${pk[$((n-1))]}"
                    echo "Details for $s:"
                    sd "$s"
                else
                    echo "Invalid number."
                fi
            elif [[ "$ch" =~ ^[0-9]+$ ]] && [ "$ch" -gt 0 ] && [ "$ch" -le ${#pk[@]} ]; then
                s="${pk[$((ch-1))]}"
                if $sd; then
                    echo "Details for $s:"
                    sd "$s"
                fi
                echo ""
                read -p "Install $s? (y/N): " cf
                if [[ $cf =~ ^[Yy]$ ]]; then
                    ip "$s"
                    break
                fi
            else
                echo "Invalid choice. Use number for install, ?number for info, or blank to exit."
            fi
        done
    else
        ip="$q"
        if $sd; then
            echo "Details for $ip:"
            sd "$ip"
        fi
        read -p "Install $ip? (y/N): " cf
        if [[ $cf =~ ^[Yy]$ ]]; then
            ip "$ip"
        fi
    fi
else
    echo "Use -l <query> to list packages, -I <package> to install, or <query> for default mode."
    exit 1
fi
if [ ! -f "$c" ]; then
{
echo "limit=$l"
echo "mode=$m"
echo "show_details=$sd"
} > "$c"
fi
if $ac; then
    acp
fi
if $cc; then
    cc
fi
if $us; then
    us
fi