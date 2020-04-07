import json
import os
from pprint import PrettyPrinter
import nltk
from nltk.corpus import stopwords
from collections import Counter 
import regex
import time

pp = PrettyPrinter(indent=2)

# copied this from stack overflow
emojidetector = regex.compile('([*#0-9](?>\\xEF\\xB8\\x8F)?\\xE2\\x83\\xA3|\\xC2[\\xA9\\xAE]|\\xE2..(\\xF0\\x9F\\x8F[\\xBB-\\xBF])?(?>\\xEF\\xB8\\x8F)?|\\xE3(?>\\x80[\\xB0\\xBD]|\\x8A[\\x97\\x99])(?>\\xEF\\xB8\\x8F)?|\\xF0\\x9F(?>[\\x80-\\x86].(?>\\xEF\\xB8\\x8F)?|\\x87.\\xF0\\x9F\\x87.|..(\\xF0\\x9F\\x8F[\\xBB-\\xBF])?|(((?<zwj>\\xE2\\x80\\x8D)\\xE2\\x9D\\xA4\\xEF\\xB8\\x8F\k<zwj>\\xF0\\x9F..(\k<zwj>\\xF0\\x9F\\x91.)?|(\\xE2\\x80\\x8D\\xF0\\x9F\\x91.){2,3}))?))')

def loadMsgs(foldername):
    messages = []
    messageTotal = 0
    memberList = set()
    for i in os.listdir(foldername):
        jsonobj = json.load(open(foldername + "/" + i, "r"))
        memberList = memberList | set([i["name"] for i in \
            jsonobj["participants"]])
        messages.append(jsonobj["messages"])
    for i in messages:
        messageTotal += len(i)
    return (messages, messageTotal, memberList)

def countMsgs(messages, emptyParam):
    msgCount = {}
    for i in messages:
        name = i["sender_name"]
        if name not in msgCount.keys(): msgCount[name] = 1
        else: msgCount[name] += 1
    return msgCount

def countWords(messages, emptyParam):
    wordCount = {}
    for i in messages:
        try:
            name = i["sender_name"]
            message = i["content"]
            if name not in wordCount.keys(): 
                wordCount[name] = len(message.split(" "))
            else: 
                wordCount[name] += len(message.split(" "))
        except:
            continue
    return wordCount

def countSpecificWord(messages, word):
    wordCount = {}
    for i in messages:
        try:
            name = i["sender_name"]
            message = i["content"]
            for i in message.split(" "):
                if name not in wordCount.keys(): 
                    wordCount[name] = 1 if word in i.lower() else 0
                else: 
                    wordCount[name] += 1 if word in i.lower() else 0
        except KeyError:
            continue
    return wordCount

def WCKowalski(messages, counter, word, divTotal):
    dct = {}
    totalMessages = {}
    if word != None: print(word)

    counts = [counter(i, word) for i in messages]

    for i in counts:
        for j in i.keys():
            if j not in dct:
                dct[j] = i[j]
            else:
                dct[j] += i[j]

    totalCounts = [countWords(i, word) for i in messages]

    for i in totalCounts:
        for j in i.keys():
            if j not in totalMessages:
                totalMessages[j] = i[j]
            else:
                totalMessages[j] += i[j]
    
    if divTotal:
        for i in dct:
            dct[i] = dct[i] / totalMessages[i]

    for i in sorted(dct, key=dct.get, \
            reverse=True):
        if (divTotal): dct[i] *= 1000
        print(i + ": " + str(dct[i]))

# def mostCommonWords(messages, name):
#     commonWords = {}
#     for i in messages:
#         try:
#             if name not in i["sender_name"] : continue
#             msgSplit = i["content"].split(" ")
#             msgSplit = list(filter(lambda x: not regex.search(emojidetector, x), msgSplit))
#             msgSplit = [i.lower() for i in msgSplit]
#             for j in msgSplit:
#                 if j not in commonWords:
#                     commonWords[j] = 1
#                 else:
#                     commonWords[j] += 1
#         except KeyError:
#             continue
    
#     return commonWords

# def MCKowalski(messages, name):
#     print(name)
#     counts = [mostCommonWords(i, name) for i in messages]

#     finalList = Counter({})
#     for i in counts:
#         finalList = finalList + Counter(i)

#     finalList = dict(filter(lambda x: x[0] not in stopwords and x[0] != "", finalList.items()))
#     for i in sorted(finalList, key=finalList.get, \
#             reverse=True):
#         print(i + ": " + str(finalList[i]))

if __name__ == "__main__":
    folderName = input("Name of folder:\t")
    msgLoad = loadMsgs(folderName)
    messages = msgLoad[0]
    print("Total messsages:\t" + str(msgLoad[1]))
    print("Messsage breakdown:")
    WCKowalski(messages, countMsgs, None, False)
    print()
    print("Word breakdown:\t")
    WCKowalski(messages, countWords, None, False)
    print()
    print("""To search for multiple words, just enter a common substring to those words.
    e.g. fuc -> fuck, fucking, fucked, etc.""")
    wordSearchList = input("Search for words (separated by comma):\t").split("\n")[0].split(",")
    for i in wordSearchList:
        i = i.strip()
        print()
        print("Search for " + i + ":\t")
        WCKowalski(messages, countSpecificWord, i, False)

    
    
