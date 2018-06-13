import unittest

CHAR_COUNT = 26
FIRST_CHAR = 'a'


def sort_by_strings(s, t):
    """
    Sort string s based on order of characters in t. Assumes all letters in t occur only once. Solution iterates
    through s and stores character counts. Then iterates through each character of t, checks the counts array for
    existence, and updates the output string accordingly.
    :param s: string to sort
    :param t: string ordering pattern
    :return: ordered string in lowercase. None if either string does not only consist of letters. None if letters
             in s do not appear in t.
    """

    if not s.isalpha() or not t.isalpha():  # ensure strings are letters
        return None

    to_sort, order = list(s.lower()), list(t.lower())

    # Store counts of each letter
    counts = [0 for _ in range(CHAR_COUNT)]
    for c in to_sort:
        counts[ord(c) - ord(FIRST_CHAR)] += 1

    # order the string
    iter = 0
    for c in order:
        index = ord(c) - ord(FIRST_CHAR)
        while counts[index] > 0:
            to_sort[iter] = c
            iter += 1
            counts[index] -= 1

    # Letter/s of to_sort are not present on the order string
    if iter != len(to_sort):
        return None

    return ''.join(to_sort)


class Test(unittest.TestCase):

    def setUp(self):
        self.cases = [
            ("drac", "carding", "card"),
            ("agurd", "guards", "guard"),
            ("14numbers5", "number", None),
            ("agurd", "guar", None),
            ("az", "za", "za"),
            ("AHZ", "JZHAG", "zha"),
            ("weather", "therapyw", "theeraw"),
            ("", "test", None),

        ]

    def test_sort_by_strings(self):
        for i in range(len(self.cases)):
            self.assertEqual(sort_by_strings(self.cases[i][0], self.cases[i][1]), self.cases[i][2])


if __name__ == '__main__':
    unittest.main()
