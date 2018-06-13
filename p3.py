import unittest

def change_possibilities(amount, denominations):
    """
    Computes the possible combinations of change that sum to a given amount. Uses dynamic programming where
    arr[i] stores the number of possibilities for amount i.
    :param amount: Total change amount.
    :param denominations: Coin values.
    :return: Number of possible combinations of coins that sum to the given amount.
    """
    arr = [0 for _ in range(amount+1)]
    arr[0] = 1

    for i in range(0, len(denominations)):
        for j in range(denominations[i], amount+1):
            arr[j] += arr[j - denominations[i]]

    return arr[amount]


class Test(unittest.TestCase):

    def setUp(self):
        self.cases = [
            (4, [1,2,3], 4),
            (6, [1,2,3], 7),
            (0, [1,2], 1),
            (7, [1,2,3,7], 9)
        ]

    def test_decode_string(self):
        for i in range(len(self.cases)):
            self.assertEqual(change_possibilities(self.cases[i][0], self.cases[i][1]), self.cases[i][2])


if __name__ == '__main__':
    unittest.main()

