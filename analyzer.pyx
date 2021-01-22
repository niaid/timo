
#cython: language_level=3

import sys
from scipy.stats.distributions import binom

FORWARD_DICT = {}
REVERSE_DICT = {}
INSERTION_DICT = {}
CONSENSUS_DICT = {}

NOTESLIST = []

def setupDictionaries(segLen=1):
    global FORWARD_DICT
    global REVERSE_DICT
    global INSERTION_DICT
    global CONSENSUS_DICT
    FORWARD_DICT = {}
    REVERSE_DICT = {}
    INSERTION_DICT = {}
    CONSENSUS_DICT = {}

    for idx in range(segLen):
        FORWARD_DICT[idx] = {}
        REVERSE_DICT[idx] = {}
        CONSENSUS_DICT[idx] = {}


def seqUpdater(cigartuple,read,readidx,readq): #as long as you don't use updater again - good. cigartuple, read, readidx,readq
    """look up cigar the aligned sequence may have additional bases that aren't in the reference or may be missing
    bases- CIGAR is a string to indicate if the reference and sequence match or mismatch due to deltions, insertions,
    soft-clipping or hard clipping. a CIGAR may look like (3M1I3M1D5M) which would stand for 3 match, 1 insertion, 3 match, 1 deletion, 5 match
    the tuple for cigartuple would look like [(0,3), (1,3), (0,3), (2,1), (0,5)]"""
    updatedcigarseq = []
    updatedseq = []
    updatedidx = []
    updatedreadq = []
    idxctr = 0
    for CIGIDX, (identifier,length) in enumerate(cigartuple):
        if identifier == 0: #match
            updatedcigarseq.extend('M'*length)
            for i in range(length):
                updatedseq.append(read[idxctr])
                updatedreadq.append(readq[idxctr])
                idxctr+=1
        elif identifier == 1: #insertion
            updatedcigarseq.extend('I'*length)
            for i in range(length):
                updatedseq.append(read[idxctr]) #with an insertion will insert idxctr
                updatedreadq.append(readq[idxctr])
                idxctr+=1
        elif identifier == 2: #deletion
            updatedcigarseq.extend('D'*length) #deletion will insert a little gap look up cigartuple
            for i in range(length):
                updatedseq.append('-')
                updatedreadq.append('-')

        elif identifier == 4: #softclip
            updatedcigarseq.extend('S'*length)
            for i in range(length):
                updatedseq.append(read[idxctr])
                updatedreadq.append(readq[idxctr])
                idxctr+=1

        elif identifier == 3: #skipped region added 4/9/2018
            pass

        elif identifier == 5: #hardclip. I put this code back. 8/30/2017
            pass
        else:

            sys.exit("cigartuple: invalid number encountered! %s in %s " % (identifier,cigartuple))

    #Because the Cigartuple doesn't come in a sequence like MMMIMMMMMDMMM - Tim wrote it out so that it matches with the sequence length
    # print cigartuple
    idxctr = 0
    last_delnt = 0
    last_insnt = 0
    for i,j,q in zip(updatedcigarseq,updatedseq,updatedreadq):
        if i == 'D':
            last_delnt+=1
            # print 'deletion',i,j,last_delnt,q
            updatedidx.append(last_delnt)
        elif i == 'I':
            # print 'insertion',i,j,last_insnt,q
            updatedidx.append(last_insnt)
            idxctr+=1
        else:
            # print i,j,readidx[idxctr],q
            updatedidx.append(readidx[idxctr])
            last_delnt = readidx[idxctr]
            last_insnt = readidx[idxctr]
            idxctr+=1
    assert len(updatedcigarseq) == len(updatedseq) == len(updatedidx) == len(updatedreadq) #check that they are all the same length assert function checks if True

    return (updatedcigarseq,updatedseq,updatedidx,updatedreadq)




"""Dictionaries: dictionary collection of many values (similar to list) but indexes for dictionaries
can use many different data types- not just integers. Indexes for dictionaries are called 'keys'. dictionaries are
typed with {} braces. Dict are not ordered like lists. B/c they are not ordered they can't be spliced
like lists can"""
def analyzer(isReverse,updatedOut, qualThresh): #takes output from above and puts in. isReverse is checking to make sure forward or reverse
    # updatedcigarseq,updatedseq,updatedidx,updatedreadq
    cig = updatedOut[0]
    seq = updatedOut[1]
    ntpos = updatedOut[2]
    qual = updatedOut[3]

    tempinsdict = {}
    if isReverse:
        # REVERSE_DICT
        for c,nt,pos,q in zip(cig,seq,ntpos,qual): #allowed to use zip because of same length take
            if pos == None and c == 'S':
                pass



            else:
                if c == 'I':
                    if pos in tempinsdict:
                        tempinsdict[pos].append(nt)
                    else:
                        tempinsdict[pos] = [nt]
                elif q == '-' or q >= qualThresh: #quality passes threshold
                    if nt in REVERSE_DICT[pos]: #position populated
                        REVERSE_DICT[pos][nt] = REVERSE_DICT[pos][nt] + 1
                    else:
                        REVERSE_DICT[pos][nt] = 1
                    if nt in CONSENSUS_DICT[pos]:
                        CONSENSUS_DICT[pos][nt] = CONSENSUS_DICT[pos][nt] + 1
                    else:
                        CONSENSUS_DICT[pos][nt] = 1
        if tempinsdict:
            for ntpos in tempinsdict:
                fullnt = ''.join(tempinsdict[ntpos])
                if ntpos in INSERTION_DICT:
                    pass
                else:
                    INSERTION_DICT[ntpos] = {}

                if fullnt in INSERTION_DICT[ntpos]:
                    INSERTION_DICT[ntpos][fullnt] = INSERTION_DICT[ntpos][fullnt] + 1
                else:
                    INSERTION_DICT[ntpos][fullnt] = 1
    else:
        #FORWARD_DICT
        for c,nt,pos,q in zip(cig,seq,ntpos,qual):
            if pos == None and c == 'S': #c == soft clip
                pass

            else:
                if c == 'I': #insertion
                    if pos in tempinsdict:
                        tempinsdict[pos].append(nt)
                    else:
                        tempinsdict[pos] = [nt]
                elif q == '-' or q >= qualThresh:
                    if nt in FORWARD_DICT[pos]:
                        FORWARD_DICT[pos][nt] = FORWARD_DICT[pos][nt] + 1
                    else:
                        FORWARD_DICT[pos][nt] = 1

                    if nt in CONSENSUS_DICT[pos]:
                        CONSENSUS_DICT[pos][nt] = CONSENSUS_DICT[pos][nt] + 1
                    else:
                        CONSENSUS_DICT[pos][nt] = 1
        if tempinsdict:
            for ntpos in tempinsdict:
                fullnt = ''.join(tempinsdict[ntpos])
                if ntpos in INSERTION_DICT:
                    pass
                else:
                    INSERTION_DICT[ntpos] = {}

                if fullnt in INSERTION_DICT[ntpos]:
                    INSERTION_DICT[ntpos][fullnt] = INSERTION_DICT[ntpos][fullnt] + 1
                else:
                    INSERTION_DICT[ntpos][fullnt] = 1



def binomCheck(ntpos, cutoff): #checking the nt position for both forward and reverse mate pairs
    fordict = FORWARD_DICT[ntpos]
    revdict = REVERSE_DICT[ntpos]


    if not fordict or not revdict:      #if either forward dict or reverse dict is empty..
        accept = False

    else:
        topF =sorted(fordict, key=fordict.get, reverse=True)[:2] #dictionaries can be in any particular order, where lists indexes start at 0
        topR =sorted(revdict, key=revdict.get, reverse=True)[:2]

        if len(topF) == 1 or len(topR) == 1:
            accept = False
            print('unequal minor variant count in forward/reverse %d' % ntpos) #%s= string %d = number variable ntpos has already been defined
            print('forward',fordict)
            print('reverse',revdict)
            NOTESLIST.append('take a closer look at, only one minorvar %d' % ntpos)
            NOTESLIST.append(fordict)
            NOTESLIST.append(revdict)
        else:
            f_majornt = topF[0] #this will be the major because it will be the first highest
            f_minornt = topF[1] #this will be the minor variant because it will be the second highest, remember that python starts numbering at 0

            r_majornt = topR[0]
            r_minornt = topR[1]

            if f_majornt != r_majornt or f_minornt != r_minornt:
                print('binom not equal')
                NOTESLIST.append('take a closer look at %d' % ntpos ) #this will be added to the notelist for what went wrong exactly
                NOTESLIST.append([f_majornt,r_majornt,f_minornt,r_minornt])
                accept = False
            else:
                forwardMajorCount = fordict[f_majornt]
                forwardMinorCount = fordict[f_minornt]

                reverseMajorCount = revdict[r_majornt]
                reverseMinorCount = revdict[r_minornt]
                ALPHA = 0.05 #to check and make sure that it is signficiant, or in a significant number of reads

                pforward = 1 - binom.cdf( forwardMinorCount, (forwardMajorCount + forwardMinorCount), cutoff) #calculating the p value
                preverse = 1 - binom.cdf( reverseMinorCount, (reverseMajorCount + reverseMinorCount), cutoff)
                if pforward <= ALPHA/2 and preverse <= ALPHA/2:
                    accept = True
                else:
                    accept = False
    return accept
