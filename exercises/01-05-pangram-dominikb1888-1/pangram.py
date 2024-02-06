from string import ascii_lowercase as lc

def is_pangram(sentence):
    return set(lc).issubset(set(sentence.lower()))
