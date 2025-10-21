# Getting Started with Ollama and LM Studio

Now it's time to actually run AI on your own computer! This guide will walk you through setting up two of the best tools for beginners: **Ollama** and **LM Studio**. We'll go step-by-step, explaining everything along the way.

You don't need to use both - pick the one that appeals to you more, or try both and see which you prefer!

---

## Quick Comparison: Ollama vs LM Studio

Before we start, here's how they compare:

| Feature | Ollama | LM Studio |
|---------|--------|-----------|
| **Interface** | Command-line (Terminal) | Graphical (like an app) |
| **Ease of use** | Moderate (need terminal comfort) | Very easy (point and click) |
| **Model discovery** | Manual (search online) | Built-in model browser |
| **Chat interface** | Through terminal or third-party apps | Built-in beautiful UI |
| **Speed** | Fast, lightweight | Fast, slightly more overhead |
| **Advanced features** | Excellent API, integrations | Good features, user-friendly |
| **Best for** | Developers, terminal users, integrations | Beginners, visual learners |
| **Platforms** | Mac, Windows, Linux | Mac, Windows, Linux |
| **Price** | Free, open source | Free |

**Recommendation**:
- **Choose LM Studio** if you're new to technology or prefer visual interfaces
- **Choose Ollama** if you're comfortable with terminal/command-line or want more flexibility
- **Try both** - they can coexist peacefully on the same computer!

---

# Part 1: Getting Started with LM Studio

LM Studio is perfect for beginners. It's like iTunes or Spotify, but for AI models.

## Step 1: Check Your System

Before installing, verify your system:

### Check Your Operating System

**Windows**:
- Windows 10 or 11 (64-bit)
- Check: Settings → System → About

**Mac**:
- macOS 12 (Monterey) or newer
- Check: Apple menu → About This Mac

**Linux**:
- Most modern distributions (Ubuntu 20.04+, etc.)
- Run: `lsb_release -a` in terminal

### Check Your Available Storage

You'll need at least 50GB free space:

**Windows**:
- Open File Explorer
- Click "This PC"
- Look at C: drive free space

**Mac**:
- Click Apple menu → About This Mac
- Go to Storage tab

**Linux**:
- Run: `df -h` in terminal
- Look at your main partition

### Check Your RAM

**Windows**:
- Press Ctrl+Shift+Esc (Task Manager)
- Go to Performance → Memory
- Note total RAM

**Mac**:
- Apple menu → About This Mac
- Memory section shows total RAM

**Linux**:
- Run: `free -h` in terminal

### Check Your GPU (Optional but Recommended)

**Windows**:
- Press Windows+R, type `dxdiag`, press Enter
- Go to Display tab
- Note your GPU model and memory

**Mac**:
- Apple menu → About This Mac
- Click Graphics/Displays
- Note your GPU

**Linux**:
- Run: `lspci | grep VGA` or `nvidia-smi` (for NVIDIA)

**What you're looking for**:
- Any NVIDIA GPU is great
- AMD GPUs work but may be slower
- Mac M1/M2/M3 chips are excellent for AI
- No GPU? You can still use CPU, just slower

[PLACEHOLDER: Link to detailed system check guides, GPU compatibility lists]

---

## Step 2: Download and Install LM Studio

### Download

1. **Visit**: https://lmstudio.ai
2. **Click** the download button for your operating system
3. **Wait** for download to complete (it's about 500MB-1GB)

### Install

**Windows**:
1. Open the downloaded `.exe` file
2. If you see a security warning, click "More info" → "Run anyway"
3. Follow the installation wizard (defaults are fine)
4. Click Finish

**Mac**:
1. Open the downloaded `.dmg` file
2. Drag LM Studio to Applications folder
3. First time opening: Right-click → Open (to bypass Gatekeeper)
4. Click "Open" in the security dialog

**Linux**:
1. Download the `.AppImage` file
2. Make it executable: `chmod +x LM-Studio-*.AppImage`
3. Run it: `./LM-Studio-*.AppImage`
4. Optional: Move to /usr/local/bin or create desktop shortcut

### First Launch

1. **Open** LM Studio
2. **Welcome screen** will appear
3. **Grant permissions** if asked (for model storage)
4. You should see the main interface with:
   - Search bar at top
   - Model browser
   - Download section

**Troubleshooting**:
- **Won't open on Mac**: Right-click → Open instead of double-clicking
- **Antivirus warning on Windows**: Add exception (LM Studio is safe)
- **Linux permission issues**: Ensure AppImage is executable

[PLACEHOLDER: Link to installation video tutorials, troubleshooting guides]

---

## Step 3: Download Your First Model

Now for the exciting part - getting a model!

### Choose Your First Model

Based on your system, pick one:

**If you have 8GB RAM and no GPU** or **basic laptop**:
→ **Llama 3.2 3B Instruct Q5_K_M** (~2GB)

**If you have 16GB RAM and/or a GPU with 8GB+ VRAM**:
→ **Llama 3.1 8B Instruct Q5_K_M** (~5.5GB)

**If you have 32GB+ RAM and a powerful GPU (16GB+ VRAM)**:
→ **Llama 3.1 70B Instruct Q4_K_M** (~40GB)

### Download Process

1. **In LM Studio**, you should be on the "Discover" or "Search" tab
2. **Type** in the search bar: `llama 3.2 3b instruct` (or your chosen model)
3. **Look for** models that say "GGUF" and have "Instruct" or "Chat" in the name
4. **Find** the quantization level:
   - Look for "Q5_K_M" or "Q4_K_M" in the name
   - These indicate the compression level
5. **Click** the download button (↓ icon) next to your chosen model variant
6. **Wait** for download - this can take a few minutes to an hour depending on size and internet speed
7. **Progress bar** will show download status

### Understanding the Model Name

Example: `Meta-Llama-3.1-8B-Instruct-Q5_K_M.gguf`

Breaking it down:
- `Meta-Llama-3.1`: Model family and version
- `8B`: 8 billion parameters (size)
- `Instruct`: Tuned for following instructions (vs base model)
- `Q5_K_M`: Quantization method (5-bit, medium)
- `.gguf`: File format

**Tips**:
- Always choose "Instruct" or "Chat" versions for conversation
- Q5 or Q4 are good starting points
- Bigger numbers in quantization (Q6, Q8) = better quality but larger size

[PLACEHOLDER: Link to model naming guide, recommended models list]

---

## Step 4: Start Chatting!

Once download completes:

### Load the Model

1. **Click** on the "Chat" tab or button (usually on the left sidebar)
2. **At the top**, you'll see "Select a model"
3. **Click** the dropdown
4. **Choose** the model you just downloaded
5. **Wait** a few seconds while it loads into memory
   - You'll see a loading indicator
   - Status will show "Model loaded" when ready

### Your First Conversation

1. **Type** a message in the text box at the bottom
   - Example: "Hello! Can you explain what you are in simple terms?"
2. **Press** Enter or click Send
3. **Wait** for response
   - You'll see tokens being generated in real-time
   - Speed depends on your hardware
4. **Continue** the conversation naturally

### What to Try

**Test understanding**:
- "Explain quantum physics like I'm five years old"
- "What's the difference between a virus and bacteria?"

**Get help with tasks**:
- "Write a professional email thanking a client"
- "Give me 5 healthy dinner ideas"

**Creative tasks**:
- "Write a short story about a robot learning to paint"
- "Help me brainstorm names for a coffee shop"

**Coding help** (if applicable):
- "Explain what a for loop is in Python"
- "Write a function to check if a number is prime"

### Understanding the Interface

**Left sidebar**:
- **Chat**: Where you have conversations
- **Discover**: Browse and download models
- **Local Server**: Advanced feature for running as API

**Top bar**:
- **Model selector**: Choose which model to use
- **Settings**: Configure parameters

**Bottom section**:
- **Text input**: Where you type messages
- **Send button**: Send your message
- **Stop button**: Stop generation if it's going wrong

**Right sidebar** (if visible):
- **Conversation history**: Previous chats
- **Parameters**: Advanced settings

[PLACEHOLDER: Link to interface tour video, tips and tricks]

---

## Step 5: Adjust Settings (Optional)

You can customize how the model responds:

### Access Settings

1. **Look for** a settings gear icon or "Model Configuration" section
2. Usually appears when a model is loaded
3. May be in the right sidebar or top area

### Key Settings to Understand

**Temperature** (0.0 - 2.0):
- **Low (0.3-0.7)**: More focused, predictable, factual
- **Medium (0.7-1.0)**: Balanced, default for most use
- **High (1.0-2.0)**: More creative, random, varied

**When to adjust**:
- Lower for factual tasks, coding, analysis
- Higher for creative writing, brainstorming

**Context Length** (tokens):
- How much conversation history the model remembers
- More = remembers more but slower and uses more memory
- Default is usually fine
- 2048-4096 is typical

**Max Tokens** (response length):
- Maximum length of each response
- -1 or 0 usually means "unlimited" (until natural stopping point)
- Set lower (e.g., 500) for concise responses

**Top P** (0.0 - 1.0):
- Alternative to temperature
- Controls randomness differently
- Default (0.9-0.95) is usually fine
- Lower = more focused

**Repeat Penalty** (1.0 - 2.0):
- Prevents model from repeating itself
- Higher = less repetition
- Default (~1.1) usually works well

**Beginner tip**: Start with defaults. Only adjust temperature when you want different creativity levels.

[PLACEHOLDER: Link to parameter tuning guide, examples of settings for different tasks]

---

## Step 6: Try Different Models

Part of the fun is experimenting with different models:

### Download Another Model

1. Go back to **Discover/Search** tab
2. Try a different model:
   - **Mistral 7B** - Good general model
   - **CodeLlama** - If you want coding help
   - **Phi-3** - Efficient Microsoft model
   - **TinyLlama** - Very small, very fast
3. Download following same process as before

### Switch Between Models

1. In **Chat** tab, use model dropdown at top
2. Select different model
3. Previous model unloads, new one loads
4. Continue chatting with new model

### Compare Performance

Try the same prompt with different models:
- Notice speed differences
- Compare quality of responses
- See which models excel at what tasks

**Example prompt to try with each**:
"Write a Python function that calculates the Fibonacci sequence"

Compare:
- Correctness of code
- Quality of explanation
- Speed of generation

---

## Common Issues and Solutions

### Issue: Model is Very Slow

**Solutions**:
- Try a smaller model (3B instead of 8B)
- Close other applications to free up RAM
- Check if model is using GPU (LM Studio shows this)
- Lower context length in settings
- Consider quantization level (Q4 instead of Q5)

### Issue: Model Gives Strange or Repetitive Responses

**Solutions**:
- Adjust temperature (try 0.7-0.8)
- Increase repeat penalty
- Try a different model
- Check if you're using an "Instruct" or "Chat" model (not base model)

### Issue: Model Won't Load / "Out of Memory"

**Solutions**:
- Model is too large for your system
- Download a smaller model or lower quantization
- Close other applications
- Restart LM Studio
- Check available RAM (Task Manager / Activity Monitor)

### Issue: Download Keeps Failing

**Solutions**:
- Check internet connection
- Check available disk space
- Try again later (server might be busy)
- Download from Hugging Face manually and import

### Issue: GPU Not Being Used

**Solutions**:
- Check LM Studio settings for GPU configuration
- Update GPU drivers
- Ensure compatible GPU (NVIDIA usually best supported)
- Some models default to CPU - check model settings

[PLACEHOLDER: Link to comprehensive troubleshooting guide, community forums]

---

# Part 2: Getting Started with Ollama

Ollama is command-line based but incredibly powerful and efficient. If you're comfortable with Terminal/Command Prompt, it's fantastic.

## Step 1: Check Your System

Same as LM Studio - verify:
- Operating system version
- Storage space (50GB+ recommended)
- RAM (8GB minimum, 16GB+ recommended)
- GPU (optional but helpful)

[Same system check instructions as above]

---

## Step 2: Install Ollama

### Download and Install

**Mac or Linux**:

1. **Open Terminal**
   - Mac: Applications → Utilities → Terminal
   - Linux: Ctrl+Alt+T or search for Terminal

2. **Run installation command**:
   ```bash
   curl -fsSL https://ollama.com/install.sh | sh
   ```

3. **Wait** for installation to complete
   - Script will download and install automatically
   - May ask for your password (for sudo access)

4. **Verify** installation:
   ```bash
   ollama --version
   ```
   - Should show version number

**Windows**:

1. **Visit**: https://ollama.com/download
2. **Click** Download for Windows
3. **Run** the installer (`.exe` file)
4. **Follow** installation wizard
5. **Verify**: Open Command Prompt or PowerShell and run:
   ```bash
   ollama --version
   ```

### What Just Happened?

Ollama installed:
- Main application
- Command-line tool
- Background service (runs in system tray)
- Model management system

[PLACEHOLDER: Link to Ollama installation video, troubleshooting]

---

## Step 3: Download and Run Your First Model

Ollama makes this incredibly simple - one command does both!

### Choose Your Model

Based on your system:

**Limited hardware (8-16GB RAM, no GPU)**:
```bash
ollama run llama3.2:3b
```

**Good hardware (16-32GB RAM, decent GPU)**:
```bash
ollama run llama3.1:8b
```

**Powerful hardware (32GB+ RAM, strong GPU)**:
```bash
ollama run llama3.1:70b
```

### Run the Command

1. **Open Terminal** (Mac/Linux) or **Command Prompt/PowerShell** (Windows)

2. **Type** your chosen command, for example:
   ```bash
   ollama run llama3.2:3b
   ```

3. **Press Enter**

4. **Wait** for download:
   - First time running a model, Ollama downloads it automatically
   - You'll see progress bar
   - Can take a few minutes depending on model size and internet

5. **Model loads** into memory
   - Another brief wait
   - Shows loading status

6. **Chat interface** appears
   - Prompt will appear: `>>>`
   - You can start typing!

### Your First Conversation

```bash
>>> Hello! What can you help me with?
```

Press Enter, and the model will respond!

Continue the conversation naturally - Ollama handles everything.

### Exit the Chat

When you're done:
- Type `/bye` and press Enter
- Or press `Ctrl+D` (Mac/Linux) or `Ctrl+C` (Windows)

### Understanding Ollama Commands

**`ollama run [model]`**: Download (if needed) and run a model
**`ollama pull [model]`**: Download a model without running
**`ollama list`**: Show all downloaded models
**`ollama rm [model]`**: Delete a model
**`ollama ps`**: Show currently running models

[PLACEHOLDER: Link to Ollama command reference, examples]

---

## Step 4: Explore Available Models

Ollama has a library of curated models ready to use.

### Browse Models

**Visit**: https://ollama.com/library

You'll find:
- Language models (Llama, Mistral, Phi, etc.)
- Code models (CodeLlama, Deepseek-Coder, etc.)
- Specialized models

### Popular Models to Try

**General conversation and tasks**:
```bash
ollama run llama3.1:8b       # Meta's excellent general model
ollama run mistral:7b        # Great all-rounder
ollama run phi3:mini         # Microsoft's efficient model
```

**Coding assistance**:
```bash
ollama run codellama:13b     # Code-specialized
ollama run deepseek-coder:6.7b # Excellent for programming
```

**Specialized**:
```bash
ollama run llama3.1:8b-vision  # Multimodal (text + images)
ollama run mixtral:8x7b        # High capability
```

### Model Tags and Variants

Models can have different tags:

```bash
llama3.1:8b        # Default (usually Q4 quantization)
llama3.1:8b-q5     # Q5 quantization (better quality, larger)
llama3.1:8b-q8     # Q8 quantization (highest quality)
llama3.1:70b       # Different size
```

**Most users**: Just use the default (no suffix after size)

---

## Step 5: Advanced Ollama Usage

### Running as a Server

Ollama can run as a server, letting other apps use it:

```bash
ollama serve
```

This starts an API server at `http://localhost:11434`

Other applications can now connect to it!

### Using the API

Send requests programmatically:

```bash
curl http://localhost:11434/api/generate -d '{
  "model": "llama3.1:8b",
  "prompt": "Why is the sky blue?",
  "stream": false
}'
```

Perfect for integrations!

### Modelfile (Advanced)

Create custom model configurations:

```bash
# Save this as Modelfile
FROM llama3.1:8b
PARAMETER temperature 0.8
SYSTEM You are a helpful coding assistant.
```

Create the custom model:
```bash
ollama create my-coding-assistant -f Modelfile
ollama run my-coding-assistant
```

[PLACEHOLDER: Link to Modelfile guide, API documentation, integration examples]

---

## Step 6: Integrate with Other Apps

Ollama works with many third-party applications!

### Chat Interfaces

**Open WebUI** (formerly Ollama WebUI):
- Beautiful web interface for Ollama
- Like ChatGPT interface but for local models
- Install: https://github.com/open-webui/open-webui

**Enchanted** (Mac only):
- Native macOS app
- Connects to Ollama
- Beautiful interface

### Development Tools

**Continue** (VS Code extension):
- AI coding assistant using Ollama
- Works in your code editor
- Free alternative to GitHub Copilot

**Cursor** (code editor):
- Can connect to Ollama
- Use local models for coding

### Other Integration Options

- **Raycast** (Mac productivity): AI-powered launcher
- **ChatGPT Desktop Apps**: Some support Ollama backend
- **Custom scripts**: Use Ollama API in your own tools

[PLACEHOLDER: Links to integration guides, app directories]

---

## CPU vs GPU Performance

Understanding what to expect:

### Performance Comparison

**Small Model (3B parameters) on different hardware**:

| Hardware | Speed (tokens/sec) | Experience |
|----------|-------------------|------------|
| Modern CPU (16GB RAM) | 5-10 | Usable, bit slow |
| Older GPU (4GB VRAM) | 15-25 | Smooth |
| Good GPU (8GB+ VRAM) | 40-80 | Very fast |
| High-end GPU (16GB+ VRAM) | 80-120+ | Instant |

**Medium Model (8B parameters)**:

| Hardware | Speed (tokens/sec) | Experience |
|----------|-------------------|------------|
| Modern CPU (16GB RAM) | 2-5 | Slow but workable |
| Good GPU (8GB VRAM) | 20-40 | Good |
| High-end GPU (16GB VRAM) | 50-80 | Excellent |

**Large Model (70B parameters)**:

| Hardware | Speed (tokens/sec) | Experience |
|----------|-------------------|------------|
| CPU | <1 | Impractical |
| Good GPU (8GB VRAM) | Can't fit | N/A |
| High-end GPU (16GB VRAM) | 3-8 (Q4) | Usable |
| Multiple GPUs/High VRAM | 15-30 | Good |

### Checking if GPU is Being Used

**Ollama automatically uses GPU** if available and compatible.

**To verify (NVIDIA GPU)**:
```bash
# In another terminal while model is running
nvidia-smi
```

Look for Ollama process using GPU memory.

**Mac (M1/M2/M3)**:
- Automatically uses unified memory
- Check Activity Monitor → GPU History

### Optimizing for CPU

If using CPU only:

1. **Use smaller models** (3B-7B)
2. **Lower quantization** (Q4 instead of Q5)
3. **Be patient** - it works, just slower
4. **Close other apps** to free RAM
5. **Consider upgrading RAM** if possible

[PLACEHOLDER: Link to performance optimization guides, hardware recommendations]

---

## Best Practices and Tips

### Managing Storage

Models take up space:

**Check model sizes**:
```bash
ollama list
```

**Remove unused models**:
```bash
ollama rm llama3.1:70b
```

**Keep what you use** regularly, remove experiments.

### When to Use Which Model

**Quick tasks, testing**:
→ Small, fast models (3B-7B)

**General conversation, daily use**:
→ Medium models (7B-13B)

**Complex reasoning, important tasks**:
→ Large models (70B+) if hardware allows

**Coding**:
→ Code-specialized models (CodeLlama, Deepseek-Coder)

### Switching Between Models

You can run different models for different tasks:

```bash
# Quick question
ollama run llama3.2:3b "What's 15% of 230?"

# Coding help
ollama run codellama:13b "Write a Python web scraper"

# Complex analysis
ollama run llama3.1:70b "Analyze this business strategy..."
```

### Updating Models

Models get updated periodically:

```bash
# Pull latest version
ollama pull llama3.1:8b
```

This updates to the newest version if available.

---

## Troubleshooting Common Issues

### "Connection refused" or "Ollama not running"

**Solution**:
```bash
# Start Ollama service
ollama serve
```

Or check if Ollama is running in system tray.

### Model is extremely slow

**Solutions**:
- Use smaller model
- Check if GPU is being used
- Close memory-intensive apps
- Lower quantization level

### Out of memory errors

**Solutions**:
- Model too large for your system
- Use smaller model or lower quantization
- Close other applications
- Restart Ollama

### Can't download models

**Solutions**:
- Check internet connection
- Check disk space
- Try again later
- Check Ollama is updated: `ollama --version`

### Model gives poor responses

**Solutions**:
- Make sure using "instruct" or "chat" variant
- Try different model
- Adjust prompts to be more specific
- Some models better at certain tasks than others

[PLACEHOLDER: Link to Ollama troubleshooting docs, community support]

---

## Comparing Your Experience: LM Studio vs Ollama

### LM Studio Advantages

✅ Visual interface - easier for beginners
✅ Built-in model browser - discover easily
✅ Chat UI included - ready to go
✅ Settings accessible - point-and-click adjustments
✅ No terminal needed

### Ollama Advantages

✅ Lightweight - minimal overhead
✅ Command-line power - automate and script
✅ Better for integrations - API-first design
✅ Faster model switching
✅ Great for developers

### Using Both Together

You can use both:
- **Ollama** for quick command-line tasks and integrations
- **LM Studio** for exploratory conversation and discovery
- They can share models (with some configuration)
- Different tools for different workflows

---

## Next Steps in Your Journey

Now that you're running AI locally:

### Week 1: Explore

- [ ] Try 3-5 different models
- [ ] Compare their responses to same prompts
- [ ] Find your favorite for general use
- [ ] Test different task types (coding, writing, analysis)

### Week 2: Integrate

- [ ] Add to your daily workflow
- [ ] Try integration with other apps (if using Ollama)
- [ ] Experiment with different settings
- [ ] Note what works well vs what doesn't

### Week 3: Optimize

- [ ] Monitor system performance
- [ ] Find optimal model size for your hardware
- [ ] Set up commonly-used models
- [ ] Remove unused models to save space

### Month 2+: Advance

- [ ] Explore fine-tuning (if interested)
- [ ] Try multimodal models (vision, etc.)
- [ ] Build custom integrations
- [ ] Join community forums
- [ ] Maybe upgrade hardware based on needs

---

## Resources and Community

### Official Documentation

**LM Studio**:
- Website: https://lmstudio.ai
- Docs: [PLACEHOLDER: Link to LM Studio docs]

**Ollama**:
- Website: https://ollama.com
- Docs: https://github.com/ollama/ollama
- Model Library: https://ollama.com/library

### Community Support

**Discord/Forums**:
- [PLACEHOLDER: Links to LM Studio Discord]
- [PLACEHOLDER: Links to Ollama Discord]
- [PLACEHOLDER: Links to LocalLLaMA subreddit]

### Learning Resources

- [PLACEHOLDER: Video tutorials for both tools]
- [PLACEHOLDER: Model comparison guides]
- [PLACEHOLDER: Hardware optimization guides]
- [PLACEHOLDER: Integration tutorials]

---

## Final Encouragement

Congratulations! You're now running AI on your own computer. This is a significant achievement that puts you ahead of most AI users.

**Remember**:
- Start small, grow gradually
- It's okay if it's slower than cloud services
- Privacy and control are worth the trade-off
- The community is helpful - ask questions!
- Have fun experimenting!

**The journey ahead**:
- You'll discover favorite models
- Performance will improve as you optimize
- You might upgrade hardware
- You'll find unique use cases
- You're learning valuable skills

Welcome to the world of local AI! 🚀

---

**Previous**: [Running AI Locally: Introduction](./06-local-ai-intro.md) | **[Back to Start](./00-introduction.md)**
