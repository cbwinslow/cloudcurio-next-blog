#!/usr/bin/env python3
"""
Script to programmatically add secrets to a GitHub repository using the GitHub API.
This script handles encryption of secrets using the repository's public key.
"""

import argparse
import json
import os
import sys
from base64 import b64encode
from nacl import encoding, public


def get_public_key(owner, repo, token):
    """
    Get the public key for a repository to encrypt secrets.
    
    Args:
        owner (str): Repository owner
        repo (str): Repository name
        token (str): GitHub personal access token
        
    Returns:
        dict: Public key information with key_id and key
    """
    import requests
    
    url = f"https://api.github.com/repos/{owner}/{repo}/actions/secrets/public-key"
    headers = {
        "Authorization": f"token {token}",
        "Accept": "application/vnd.github.v3+json"
    }
    
    response = requests.get(url, headers=headers)
    response.raise_for_status()
    
    return response.json()


def encrypt_secret(public_key: str, secret_value: str) -> str:
    """
    Encrypt a secret using the repository's public key.
    
    Args:
        public_key (str): Public key from GitHub
        secret_value (str): Secret value to encrypt
        
    Returns:
        str: Base64 encoded encrypted secret
    """
    public_key_bytes = public.PublicKey(public_key.encode("utf-8"), encoding.Base64Encoder())
    sealed_box = public.SealedBox(public_key_bytes)
    encrypted = sealed_box.encrypt(secret_value.encode("utf-8"))
    return b64encode(encrypted).decode("utf-8")


def add_secret(owner, repo, token, secret_name, secret_value):
    """
    Add or update a secret in a GitHub repository.
    
    Args:
        owner (str): Repository owner
        repo (str): Repository name
        token (str): GitHub personal access token
        secret_name (str): Name of the secret
        secret_value (str): Value of the secret
    """
    import requests
    
    # Get the public key
    public_key_info = get_public_key(owner, repo, token)
    
    # Encrypt the secret
    encrypted_value = encrypt_secret(public_key_info["key"], secret_value)
    
    # Add the secret
    url = f"https://api.github.com/repos/{owner}/{repo}/actions/secrets/{secret_name}"
    headers = {
        "Authorization": f"token {token}",
        "Accept": "application/vnd.github.v3+json"
    }
    data = {
        "encrypted_value": encrypted_value,
        "key_id": public_key_info["key_id"]
    }
    
    response = requests.put(url, headers=headers, json=data)
    
    if response.status_code in [201, 204]:
        print(f"Successfully added/updated secret '{secret_name}'")
    else:
        print(f"Failed to add secret '{secret_name}': {response.status_code} - {response.text}")
        response.raise_for_status()


def main():
    parser = argparse.ArgumentParser(description="Add secrets to a GitHub repository")
    parser.add_argument("--owner", required=True, help="Repository owner")
    parser.add_argument("--repo", required=True, help="Repository name")
    parser.add_argument("--token", required=True, help="GitHub personal access token")
    parser.add_argument("--secret-name", required=True, help="Name of the secret to add")
    parser.add_argument("--secret-value", required=True, help="Value of the secret to add")
    
    args = parser.parse_args()
    
    try:
        add_secret(
            owner=args.owner,
            repo=args.repo,
            token=args.token,
            secret_name=args.secret_name,
            secret_value=args.secret_value
        )
    except Exception as e:
        print(f"Error: {e}")
        sys.exit(1)


if __name__ == "__main__":
    main()