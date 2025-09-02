#!/usr/bin/env bash


set -e

cleanup() {
  local dir="$1"
  if [ -d "$dir" ]; then
    echo "Removing existing directory: $dir"
    rm -rf "$dir"
  fi
}

echo "Choose a framework to create a new project:"
options=("Next.js" "Turborepo" "shadcn Next" "shadcn Turbo" "Next Forge" "Install All" "Clean All" "Quit")
select opt in "${options[@]}"
do
  case $opt in
    "Next.js")
      cleanup "fresh-next"
      pnpm create next-app@latest fresh-next --yes
      break
      ;;
    "Turborepo")
      cleanup "fresh-turbo"
      pnpm dlx create-turbo@latest fresh-turbo --package-manager pnpm
      break
      ;;
    "shadcn Next")
      cleanup "fresh-shadcn-next"
      pnpm create next-app@latest fresh-shadcn-next --yes --use-pnpm
      (cd fresh-shadcn-next && pnpm dlx shadcn@canary init -y)
      break
        ;;
    "shadcn Turbo")
      cleanup "fresh-shadcn-turbo"
      printf 'fresh-shadcn-turbo\n' | pnpm dlx shadcn@canary init -t next-monorepo -d -y
      break
      ;;
    "Next Forge")
      cleanup "fresh-next-forge"
      printf 'fresh-next-forge\npnpm\n' | pnpm dlx next-forge@latest init
      break
      ;;
    "Install All")
      # Clean and install Next.js
      cleanup "fresh-next"
      pnpm create next-app@latest fresh-next --yes

      # Clean and install Turborepo
      cleanup "fresh-turbo"
      pnpm dlx create-turbo@latest fresh-turbo --package-manager pnpm

      # Clean and install shadcn Next
      cleanup "fresh-shadcn-next"
      pnpm create next-app@latest fresh-shadcn-next --yes --use-pnpm
      (cd fresh-shadcn-next && pnpm dlx shadcn@canary init -y)

      # Clean and install shadcn Turbo (monorepo)
      cleanup "fresh-shadcn-turbo"
      printf 'fresh-shadcn-turbo\n' | pnpm dlx shadcn@canary init -t next-monorepo -d -y

      # Clean and install Next Forge
      cleanup "fresh-next-forge"
      printf 'fresh-next-forge\npnpm\n' | pnpm dlx next-forge@latest init

      break
      ;;
    "Clean All")
      cleanup "fresh-next"
      cleanup "fresh-turbo"
      cleanup "fresh-shadcn-next"
      cleanup "fresh-shadcn-turbo"
      cleanup "fresh-next-forge"
      break
      ;;
    "Quit")
      echo "Exiting."
      break
      ;;
    *)
      echo "Invalid option."
      ;;
  esac
done