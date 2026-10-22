bool hasBit(int? permissions, int bit) => ((permissions ?? 0) & bit) == bit;

int addBit(int permissions, int bit) => permissions | bit;

int removeBit(int permissions, int bit) => permissions & ~bit;
