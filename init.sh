#!/usr/bin/env bash
set -e

cleanup() {
  local dir="$1"
  if [ -d "$dir" ]; then
    echo "Removing existing directory: $dir"
    rm -rf "$dir"
  fi
}

# Helper: detect expect
have_expect() { command -v expect >/dev/null 2>&1; }

# Helper: run next-forge init via expect
run_next_forge_expect() {
  /usr/bin/env expect <<'EOX'
  set timeout -1
  spawn pnpm dlx next-forge@latest init
  expect {
    -re {What is your project named\?} { send -- "fresh-next-forge\r"; exp_continue }
    -re {Which package manager.*} { send -- "pnpm\r"; exp_continue }
    eof
  }
EOX
}

# Helper: run shadcn turbo init via expect
run_shadcn_turbo_expect() {
  /usr/bin/env expect <<'EOY'
  set timeout -1
  spawn pnpm dlx shadcn@canary init -t next-monorepo -d -y
  expect {
    -re {What is your project named\?} { send -- "fresh-shadcn-turbo\r"; exp_continue }
    eof
  }
EOY
}

install_next() {
  cleanup "fresh-next"
  pnpm create next-app@latest fresh-next --yes
  rm -rf fresh-next/.git
}

install_turbo() {
  cleanup "fresh-turbo"
  pnpm dlx create-turbo@latest fresh-turbo --package-manager pnpm
  rm -rf fresh-turbo/.git
}

install_shadcn_next() {
  cleanup "fresh-shadcn-next"
  pnpm create next-app@latest fresh-shadcn-next --yes --use-pnpm
  (cd fresh-shadcn-next && printf 'neutral\n' | pnpm dlx shadcn@canary init -y)
  rm -rf fresh-shadcn-next/.git
}

install_shadcn_turbo() {
  cleanup "fresh-shadcn-turbo"
  if have_expect; then
    run_shadcn_turbo_expect
    rm -rf fresh-shadcn-turbo/.git
  else
    printf 'fresh-shadcn-turbo\n' | pnpm dlx shadcn@canary init -t next-monorepo -d -y
    rm -rf fresh-shadcn-turbo/.git
  fi
}

install_next_forge() {
  cleanup "fresh-next-forge"
  if have_expect; then
    run_next_forge_expect
    rm -rf fresh-next-forge/.git
  else
    printf 'fresh-next-forge' | pnpm dlx next-forge@latest init --package-manager pnpm
    rm -rf fresh-next-forge/.git
  fi
}

# Detect argument and set opt directly if provided
if [ -n "$1" ]; then
  opt="$1"
fi

# Show the select menu only if no argument was passed
if [ -z "$opt" ]; then
  echo "Choose a framework to create a new project:"
  options=("Next.js" "Turborepo" "shadcn Next" "shadcn Turbo" "Next Forge" "Install All" "Clean All" "Quit")
  select opt in "${options[@]}"; do
    break
  done
fi
case $opt in
  "Next.js")
    install_next
    exit 0
    ;;
  "Turborepo")
    install_turbo
    exit 0
    ;;
  "shadcn Next")
    install_shadcn_next
    exit 0
    ;;
  "shadcn Turbo")
    install_shadcn_turbo
    exit 0
    ;;
  "Next Forge")
    install_next_forge
    exit 0
    ;;
  "Install All")
    install_next
    install_turbo
    install_shadcn_next
    install_shadcn_turbo
    install_next_forge
    exit 0
    ;;
  "Clean All")
    cleanup "fresh-next"
    cleanup "fresh-turbo"
    cleanup "fresh-shadcn-next"
    cleanup "fresh-shadcn-turbo"
    cleanup "fresh-next-forge"
    exit 0
    ;;
  "Quit")
    echo "Exiting."
    exit 0
    ;;
  *)
    echo "Invalid option."
    exit 1
    ;;
esac