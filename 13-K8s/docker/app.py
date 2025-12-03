"""
Local LLM-powered flight data analysis using Llama 3.2
Loads flight data and uses a locally-running Hugging Face model for analysis
"""

import pandas as pd
from transformers import AutoTokenizer, AutoModelForCausalLM
import os
import sys
from huggingface_hub import login


def authenticate_huggingface():
    """
    Authenticate with Hugging Face using token from environment variable
    """
    hf_token = os.environ.get('HUGGINGFACE_TOKEN')
    if not hf_token:
        print("ERROR: HUGGINGFACE_TOKEN environment variable not set", file=sys.stderr)
        print("You need a Hugging Face token to access Meta's Llama models", file=sys.stderr)
        print("Get one from: https://huggingface.co/settings/tokens", file=sys.stderr)
        sys.exit(1)
    
    print("Authenticating with Hugging Face...")
    login(token=hf_token, new_session=True)
    print("Authentication successful!")


def load_model(model_name="meta-llama/Llama-3.2-1B-Instruct"):
    """
    Load the Hugging Face model and tokenizer
    """
    print(f"Loading model: {model_name}")
    print("This may take a few minutes on first run...")
    
    tokenizer = AutoTokenizer.from_pretrained(model_name)
    model = AutoModelForCausalLM.from_pretrained(model_name)
    
    print("Model loaded successfully!")
    print(f"Model device: {model.device}")
    
    return tokenizer, model


def load_and_process_data():
    """
    Load the local CSV file (bundled in the Docker image) and sort by count.
    """
    script_dir = os.path.dirname(os.path.abspath(__file__))
    csv_path = os.path.join(script_dir, "2015-summary.csv")

    print(f"Loading data from {csv_path}...")
    summary = pd.read_csv(csv_path)

    summary = summary.sort_values("count", ascending=False)
    top_routes = summary.head()

    print(f"Loaded {len(summary)} total routes")
    print("\nTop 5 routes:")
    print(top_routes)

    return top_routes


def analyze_with_local_llm(data, tokenizer, model, max_tokens=250):
    """
    Analyze data using locally-running LLM
    """
    print("\nGenerating analysis with local LLM...")
    
    prompt = (
        "The following includes some of the most common international flight routes "
        "within our airline. Please only list the international routes and briefly "
        "suggest what this means for our team's short term operations: "
        f"{data}"
    )
    
    messages = [{"role": "user", "content": prompt}]
    
    inputs = tokenizer.apply_chat_template(
        messages,
        add_generation_prompt=True,
        tokenize=True,
        return_dict=True,
        return_tensors="pt",
    ).to(model.device)
    
    outputs = model.generate(**inputs, max_new_tokens=max_tokens)
    response = tokenizer.decode(outputs[0][inputs["input_ids"].shape[-1]:])
    
    return response


def main():
    print("=" * 80)
    print("Flight Route Analysis with Local Llama 3.2 LLM")
    print("=" * 80)

    try:
        # Read model name + token limit from env if the user sets them
        model_name = os.environ.get('MODEL_NAME', 'meta-llama/Llama-3.2-1B-Instruct')
        max_tokens = int(os.environ.get('MAX_TOKENS', '250'))

        authenticate_huggingface()
        tokenizer, model = load_model(model_name)
        top_routes = load_and_process_data()
        analysis = analyze_with_local_llm(top_routes, tokenizer, model, max_tokens)
        
        print("\n" + "=" * 80)
        print("LLM ANALYSIS")
        print("=" * 80)
        print(analysis)
        print("=" * 80)

        return 0

    except Exception as e:
        print(f"\nError occurred: {str(e)}", file=sys.stderr)
        import traceback
        traceback.print_exc()
        return 1


if __name__ == "__main__":
    exit_code = main()
    sys.exit(exit_code)
