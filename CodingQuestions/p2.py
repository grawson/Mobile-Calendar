import unittest

def decode_string(s):
    """
    Decode a string based on the pattern k[encoded_string]. Uses two stacks, one to store the integer counts and
    another to store the associated string. Solution computes the string from the inside out and stores it as a suffix so
    as not to perform redundant work
    :param s: encoded string
    :return: Decoded string, else None if string pattern is invalid.
    """

    if not validate(s):
        return None

    counts, strings, curr_val = list(), list(), list()
    suffix = ""
    iter = 0

    while iter < len(s):

        # string endpoint
        if (s[iter].isdigit() or s[iter] == "]") and len(curr_val) > 0:
            strings.append(''.join(curr_val))
            curr_val = []

        # number endpoint
        elif s[iter] == "[":
            counts.append(int(''.join(curr_val)))
            curr_val = []

        # pop the latest values and create a new suffix
        if s[iter] == "]":
            count, str = counts.pop(), strings.pop()
            new_suffix = ""
            for i in range(count):
                new_suffix += str + suffix
            suffix = new_suffix

        # Update current value
        if s[iter].isdigit() or s[iter].isalpha():
            curr_val.append(s[iter])

        iter += 1

    return suffix


def validate(s):
    stack = list()
    for i in range(len(s)):

        if s[i] == "[":
            # Check digit/letter pattern
            if i == 0 or not s[i - 1].isdigit(): return False
            if i < len(s)-1 and not s[i + 1].isalpha(): return False
            stack.append("[")

        elif s[i] == "]":    # match brackets
            if len(stack) == 0:
                return False
            stack.pop()

    return len(stack) == 0


class Test(unittest.TestCase):

    def setUp(self):
        self.cases = [
            ("4[ab]", "abababab"),
            ("2[b3[a]]", "baaabaaa"),
            ("2[az1[bb2[c]]]", "azbbccazbbcc"),
            ("", ""),

            # invalid format
            ("2[b3[a]", None),
            ("[b3[a]]", None),
            ("2[b3[]]", None),
            ("4[ab", None),
            ("4[ab]]]", None),
        ]

    def test_decode_string(self):
        for i in range(len(self.cases)):
            self.assertEqual(decode_string(self.cases[i][0]), self.cases[i][1])


if __name__ == '__main__':
    unittest.main()
