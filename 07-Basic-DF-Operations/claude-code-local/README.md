# Claude Code on a free local model

Lecture 07 handout for running Claude Code against Gemma 4 on your own laptop through Ollama, with no API bill.

- `07-Claude-Code-Local-Model.docx` has every step, with screenshots, plus a cleanup section.
- `settings.json` is the lab-folder settings file from step 4. It goes in `~/qst843-claude/.claude/settings.json`.

The short version, once Ollama is installed and the context length is set to 128k:

```bash
ollama pull gemma4:12b
mkdir -p ~/qst843-claude/.claude
cp settings.json ~/qst843-claude/.claude/settings.json
cd ~/qst843-claude
claude --model gemma4:12b --tools "Read,Write,Edit,Bash"
```

The settings apply only inside `~/qst843-claude`. Run `claude` from any other folder and you get your regular Claude Code.
