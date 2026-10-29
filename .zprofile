# Homebrew
eval "$(/opt/homebrew/bin/brew shellenv zsh)"

# PATH
export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/.docker/bin:$PATH"                         # Docker Desktop CLI
export PATH="/opt/homebrew/lib/ruby/gems/4.0.0/bin:$PATH"     # CocoaPods (gem on Homebrew Ruby)

# Android SDK
export ANDROID_HOME="$HOME/Library/Android/sdk"
export PATH="$ANDROID_HOME/emulator:$ANDROID_HOME/platform-tools:$PATH"

# Claude Code
export CLAUDE_CODE_NO_FLICKER=1
