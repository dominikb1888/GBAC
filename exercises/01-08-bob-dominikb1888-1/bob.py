def response(hey_bob):
    # Data pre-processing: Stripping Whitespace
    hey_bob = hey_bob.strip()

    # Guard clause: Early return for NONE/NULL values
    if not hey_bob:
        return "Fine. Be that way!"

    # Preparing our conditions as variables
    yell = hey_bob.isupper()
    question = hey_bob.endswith('?')

    if yell and question:
        return "Calm down, I know what I'm doing!"

    if yell:
        return "Whoa, chill out!"

    if question:
        return "Sure."

    return "Whatever."
