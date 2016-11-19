#!/usr/bin/python
import sys
import numpy as np

class NaiveBayes():
	
	def Train(self, filename):

		Vocabulary_Pos = {}
		Vocabulary_Neg = {}

		NumOfPos = 0
		NumOfNeg = 0

		for train_name in open(filename).read().splitlines():

			if train_name[:3] == "con": #con-->positive
				NumOfPos += 1
				for word in open(train_name).read().lower().splitlines():
					if word in Vocabulary_Pos:
						Vocabulary_Pos[word] += 1
					else:
						Vocabulary_Pos[word] = 1

					if word not in Vocabulary_Neg:
						Vocabulary_Neg[word] = 0


			elif train_name[:3] == "lib": #lib-->negative
				NumOfNeg += 1
				for word in open(train_name).read().lower().splitlines():
					if word in Vocabulary_Neg:
						Vocabulary_Neg[word] += 1
					else:
						Vocabulary_Neg[word] = 1

					if word not in Vocabulary_Pos:
						Vocabulary_Pos[word] = 0


		p_Pos = NumOfPos/float(NumOfPos + NumOfNeg)
		p_Neg = NumOfNeg/float(NumOfPos + NumOfNeg)


		return Vocabulary_Pos, Vocabulary_Neg, p_Pos, p_Neg

			
	def Test(self, filename, Vocabulary_Pos, Vocabulary_Neg, p_Pos, p_Neg):

		numOfCorrect = 0
		numOfTest = 0

		for test_name in open(filename).read().splitlines():

			v_Pos = np.log(p_Pos)
			v_Neg = np.log(p_Neg)
			numOfTest += 1
			lenOfPosText = sum(Vocabulary_Pos.values())
			lenOfNegText = sum(Vocabulary_Neg.values())
			lenOfVocabulary = len(Vocabulary_Pos)

			for word in open(test_name).read().lower().splitlines():

				if word in Vocabulary_Pos:
					v_Pos += np.log((Vocabulary_Pos[word]+1)/float(lenOfPosText+lenOfVocabulary))
				if word in Vocabulary_Neg:
					v_Neg += np.log((Vocabulary_Neg[word]+1)/float(lenOfNegText+lenOfVocabulary))

			if v_Pos >= v_Neg:
				sys.stdout.write("C\n")
				if test_name[:3] == "con":
					numOfCorrect += 1

			else:
				sys.stdout.write("L\n")
				if test_name[:3] == "lib":
					numOfCorrect += 1

		Accuracy = numOfCorrect/float(numOfTest)
		sys.stdout.write("Accuracy: %.04f" %Accuracy)
		
if __name__ == "__main__":
	Classifier = NaiveBayes();
	Vocabulary_Pos, Vocabulary_Neg, p_Pos, p_Neg = Classifier.Train(sys.argv[1])
	Classifier.Test(sys.argv[2],Vocabulary_Pos, Vocabulary_Neg, p_Pos, p_Neg)