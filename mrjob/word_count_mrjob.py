from mrjob.job import MRJob
import string

class MRWordFreqCount(MRJob):

    def mapper(self, _, line):
        # remove leading and trailing whitespace
        line = line.strip()
        # remove punctuation
        line = line.translate(None, string.punctuation)
        # split the line into words
        words = line.split()
        # increase counters
        for word in words:
            # write the results to STDOUT (standard output);
            # what we output here will be the input for the
            # Reduce step, i.e. the input for reducer.py
            #
            # tab-delimited; the trivial word count is 1
            yield word, 1

    def reducer(self, word, counts):
        yield word, sum(counts)


if __name__ == '__main__':
    MRWordFreqCount.run()
