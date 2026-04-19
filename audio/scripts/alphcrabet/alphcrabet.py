#!/usr/bin/env python3
"""
AlphCrabet - Speech Synthesizer using Crab Character Loudspeaker Voice Syllables

This script takes a plaintext English sentence and synthesizes it using
pre-recorded alphabet audio files. Each letter is mapped to its corresponding
audio file, and the files are overlaid with staggered start times.

Usage:
    python alphcrabet.py <name> <gap_ms> <sentence> [--output <filename>]

Arguments:
    name        Voice folder to use (andy, jenny, ryan, zack) - case insensitive
    gap_ms      Time in milliseconds between START times of audio files
    sentence    Plaintext English sentence to synthesize
    --output    Optional output filename (default: output.mp3)

Examples:
    python alphcrabet.py andy 100 "Hello world"
    python alphcrabet.py Jenny 150 "Test sentence" --output my_output.mp3
"""

import argparse
import sys
from pathlib import Path
from pydub import AudioSegment
from pydub.utils import mediainfo


# Base path to the sound files
SOUND_BASE_PATH = Path("../../Sound/Crab Character Loudspeaker Voice Syllables")

def get_voice_folder(name: str) -> Path:
    """
    Find the voice folder case-insensitively.
    Returns the actual folder path if found, None otherwise.
    """
    if not SOUND_BASE_PATH.exists():
        print(f"Error: Sound base path does not exist: {SOUND_BASE_PATH}")
        return None
    
    # List all directories in the base path
    for folder in SOUND_BASE_PATH.iterdir():
        if folder.is_dir() and folder.name.lower() == name.lower():
            return folder
    
    return None


def get_letter_path(voice_folder: Path, letter: str, name: str) -> Path:
    """
    Get the path to the audio file for a specific letter.
    File naming format: {Letter}_{Name}.mp3
    """
    filename = f"{letter.upper()}_{name.capitalize()}.mp3"
    return voice_folder / filename


def check_required_files(voice_folder: Path, name: str, sentence: str) -> list:
    """
    Check if all required audio files exist before processing.
    Returns a list of missing files.
    """
    missing_files = []
    unique_letters = set()
    
    # Extract unique letters from sentence
    for char in sentence.upper():
        if char.isalpha():
            unique_letters.add(char)
    
    # Check if each letter file exists
    for letter in sorted(unique_letters):
        letter_path = get_letter_path(voice_folder, letter, name)
        if not letter_path.exists():
            missing_files.append(str(letter_path))
    
    return missing_files


def get_audio_duration(filepath: Path) -> float:
    """
    Get audio duration in milliseconds from metadata.
    This is much faster than loading the full audio file.
    """
    try:
        info = mediainfo(str(filepath))
        duration_sec = float(info.get('duration', 0))
        return duration_sec * 1000  # Convert to milliseconds
    except (KeyError, ValueError) as e:
        print(f"Warning: Could not read duration from {filepath}: {e}")
        return 1000  # Default to 1 second if metadata unavailable


def collect_letter_info(voice_folder: Path, name: str, gap_ms: int, sentence: str):
    """
    Collect letter information and calculate estimated output duration.
    
    Returns:
        - letter_segments: List of tuples (start_position, letter_path)
        - max_end_time: Estimated final audio duration in milliseconds
    """
    word_gap_ms = gap_ms * 1.5
    letter_segments = []
    current_position = 0
    max_end_time = 0
    
    for char in sentence:
        if char.isalpha():
            letter_path = get_letter_path(voice_folder, char, name)
            
            # Get duration from metadata (fast, doesn't load full audio)
            duration = get_audio_duration(letter_path)
            
            # Store letter with its start position and path
            letter_segments.append((current_position, letter_path))
            
            # Calculate end time and update max
            end_time = current_position + duration
            max_end_time = max(max_end_time, end_time)
            
            # Increment position for next letter
            current_position += gap_ms
            
        elif char.isspace() or char in '.,!?':
            # Add word boundary delay
            current_position += word_gap_ms
            
        else:
            # Other characters - skip them
            continue
    
    return letter_segments, max_end_time


def synthesize_sentence(letter_segments: list, max_end_time: int) -> AudioSegment:
    """
    Synthesize the sentence by overlaying letter audio files at calculated positions.
    
    Args:
        letter_segments: List of tuples (start_position, letter_path)
        max_end_time: Pre-calculated duration for the output audio
    
    Returns:
        AudioSegment with all letters overlaid at their positions
    """
    if not letter_segments:
        return AudioSegment.empty()
    
    # Create a silent base audio with pre-calculated size
    result = AudioSegment.silent(duration=int(max_end_time))
    
    # Load and overlay each letter at its calculated position
    for position, letter_path in letter_segments:
        letter_audio = AudioSegment.from_mp3(str(letter_path))
        result = result.overlay(letter_audio, position=position)
    
    return result


def main():
    parser = argparse.ArgumentParser(
        description="Synthesize speech from alphabet audio files.",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  python alphcrabet.py andy 100 "Hello world"
  python alphcrabet.py Jenny 150 "Test sentence" --output my_output.mp3
        """
    )
    
    parser.add_argument(
        "name",
        help="Voice folder to use (andy, jenny, ryan, zack) - case insensitive"
    )
    parser.add_argument(
        "gap",
        type=int,
        help="Time in milliseconds between START times of audio files"
    )
    parser.add_argument(
        "sentence",
        help="Plaintext English sentence to synthesize"
    )
    parser.add_argument(
        "--output",
        "-o",
        default="output.mp3",
        help="Output filename (default: output.mp3)"
    )
    
    args = parser.parse_args()
    
    # Validate gap is positive
    if args.gap <= 0:
        print(f"Error: Gap must be a positive number (got {args.gap})")
        sys.exit(1)
    
    # Find voice folder (case-insensitive)
    voice_folder = get_voice_folder(args.name)
    if voice_folder is None:
        available = [f.name for f in SOUND_BASE_PATH.iterdir() if f.is_dir()]
        print(f"Error: Voice folder '{args.name}' not found.")
        print(f"Available folders: {', '.join(available)}")
        sys.exit(1)
    
    print(f"Using voice: {voice_folder.name}")
    print(f"Gap between letter starts: {args.gap}ms")
    print(f"Word/punctuation gap: {args.gap * 5}ms")
    print(f"Sentence: '{args.sentence}'")
    
    # Check if all required files exist
    print("\nChecking required audio files...")
    missing = check_required_files(voice_folder, voice_folder.name, args.sentence)
    
    if missing:
        print(f"\nError: The following required audio files are missing:")
        for filepath in missing:
            print(f"  - {filepath}")
        sys.exit(1)
    
    print("All required files found.")
    
    # Collect letter info and calculate estimated duration from metadata
    print("\nAnalyzing audio files...")
    letter_segments, estimated_duration = collect_letter_info(
        voice_folder, voice_folder.name, args.gap, args.sentence
    )
    
    if not letter_segments:
        print("No valid letters found in sentence.")
        sys.exit(1)
    
    print(f"Estimated output duration: {estimated_duration / 1000:.2f} seconds")
    
    # Synthesize the sentence
    print("\nSynthesizing audio...")
    try:
        result = synthesize_sentence(letter_segments, estimated_duration)
    except Exception as e:
        print(f"Error during synthesis: {e}")
        sys.exit(1)
    
    # Export the result
    output_path = Path(args.output)
    print(f"Exporting to: {output_path.absolute()}")
    
    try:
        result.export(str(output_path), format="mp3")
        print(f"\nSuccess! Output saved to: {output_path}")
        print(f"Actual duration: {len(result) / 1000:.2f} seconds")
    except Exception as e:
        print(f"Error exporting audio: {e}")
        sys.exit(1)


if __name__ == "__main__":
    main()
