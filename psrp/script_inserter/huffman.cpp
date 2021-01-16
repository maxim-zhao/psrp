/*
Phantasy Star: Huffman Compressor
*/

#include <string>
#include <vector>
#include <fstream>
#include <iostream>
#include <iterator>
#include <sstream>
#include <iomanip>
#include <list>
#include <map>
#include <set>
#include "ScriptItem.h"


#define EOS 0x66 // end-of-string

// Helper class for streaming bits separated into bytes
class BitWriter
{
    int _bitCount = 8;
    int _byteCount = 0;
    std::ostream& _s;
public:
    explicit BitWriter(std::ostream& s): _s(s)
    {
    }

    ~BitWriter()
    {
        try
        {
            // Pad to 8 bits
            while (_bitCount < 8)
            {
                add(false);
            }
        }
        catch (const std::exception&)
        {
            // ignore it
        }
    }

    void add(bool bit)
    {
        if (_bitCount == 8)
        {
            _s << " %";
            _bitCount = 0;
            ++_byteCount;
        }
        _s << (bit ? 1 : 0);
        ++_bitCount;
    }

    int getBytes() const
    {
        return _byteCount;
    }
};

class Tree
{
public:
    // Node holding a value, or a parent to other nodes
    class Node
    {
        Node* _pLeft = nullptr;
        Node* _pRight = nullptr;
        int _count;
        int _symbol = -1;
        std::list<bool> _codeWord;

    public:
        // Value version
        Node(int symbol, int count):
            _count(count),
            _symbol(symbol)
        {
        }

        // Parent version
        Node(Node* pLeft, Node* pRight):
            _pLeft(pLeft),
            _pRight(pRight),
            _count(pLeft->_count + pRight->_count)
        {
            _pLeft->prefixCodeword(false);
            _pRight->prefixCodeword(true);
        }

        ~Node()
        {
            delete _pLeft;
            delete _pRight;
        }

        // Comparison operator
        bool operator<(Node& other) const
        {
            return _count < other._count;
        }

        int getSymbol() const { return _symbol; }

        // Stringify values in the tree, right to left
        int symbols(std::ostream& s) const
        {
            if (_symbol > -1)
            {
                s << " $" << std::hex << std::setw(2) << std::setfill('0') << _symbol;
                return 1;
            }
            return _pRight->symbols(s) + _pLeft->symbols(s);
        }

        // Stringify each node's type (1 = value, 0 = parent), left to right
        void structure(BitWriter& bw) const
        {
            if (_symbol > -1)
            {
                bw.add(true);
                return;
            }
            bw.add(false);
            _pLeft->structure(bw);
            _pRight->structure(bw);
        }

        const std::list<bool>& getCodeword() const { return _codeWord; };

    private:
        void prefixCodeword(bool isRightNode)
        {
            // If we are a value node, do it; else push to children
            if (_pLeft == nullptr)
            {
                _codeWord.push_front(isRightNode);
            }
            else
            {
                _pLeft->prefixCodeword(isRightNode);
                _pRight->prefixCodeword(isRightNode);
            }
        }
    };

private:
    Node* _pRoot = nullptr;
    std::string _name;
    std::map<int, Node*> _leavesBySymbol;

public:
    static void insertNode(std::list<Node*>& list, Node* pNode)
    {
        // Find the rightmost place to put this one
        for (auto it = list.begin(); it != list.end(); ++it)
        {
            if (**it < *pNode)
            {
                list.insert(it, pNode);
                return;
            }
        }
        // Nowhere found, must go at the end
        list.push_back(pNode);
    }

    Tree(const int preceding, const std::vector<Node*>& nodes)
    {
        std::stringstream ss(std::ios::out | std::ios::ate);
        ss << "HuffmanTree" << std::hex << std::setw(2) << std::setfill('0') << std::uppercase << preceding;
        _name = ss.str();

        if (nodes.empty())
        {
            // Nothing to do
            _pRoot = nullptr;
            return;
        }

        // First we copy the nodes into a list, in order
        std::list<Node*> orderedNodes;

        for (auto pNode : nodes)
        {
            insertNode(orderedNodes, pNode);
        }

        // Then we combine them into a tree
        while (orderedNodes.size() > 1)
        {
            // When we build the tree, we put the smaller pair on the left.
            const auto pLeft = orderedNodes.back();
            orderedNodes.pop_back();
            const auto pRight = orderedNodes.back();
            orderedNodes.pop_back();
            const auto pNode = new Node(pLeft, pRight);
            insertNode(orderedNodes, pNode);
        }

        // And keep the root
        _pRoot = orderedNodes.front();

        // We also hold onto the leaves for easy lookup
        for (auto&& pNode : nodes)
        {
            _leavesBySymbol[pNode->getSymbol()] = pNode;
        }
    }

    ~Tree()
    {
        delete _pRoot; // recursively deletes whole tree
    }

    Tree(const Tree& other) = delete;

    Tree(Tree&& other) noexcept
        : _pRoot{other._pRoot},
          _name{std::move(other._name)},
          _leavesBySymbol{std::move(other._leavesBySymbol)}
    {
        other._pRoot = nullptr; // they're my nodes now
    }

    Tree& operator=(Tree other) = delete;

    int symbols(std::ostream& s) const
    {
        int result = 0;
        if (_pRoot != nullptr)
        {
            s << ".db";
            result = _pRoot->symbols(s);
            s << '\n';
        }
        return result;
    }

    int structure(std::ostream& s) const
    {
        int result = 0;
        if (_pRoot != nullptr)
        {
            s << ".db";
            {
                // Scope so BitWriter destructs when it is done
                BitWriter bw(s);
                _pRoot->structure(bw);
                result = bw.getBytes();
            }
            s << '\n';
        }
        return result;
    }

    bool isEmpty() const
    {
        return _pRoot == nullptr;
    }

    const std::string& getName() const
    {
        return _name;
    }

    std::list<bool> getCodeword(int symbol) const
    {
        const auto it = _leavesBySymbol.find(symbol);
        if (it == _leavesBySymbol.end())
        {
            return std::list<bool>();
        }
        return it->second->getCodeword();
    }
};

void BuildHuffmanTree(const std::string& treeFilename, std::vector<Tree>& trees, const std::vector<ScriptItem>& script)
{
    // Build symbol statistics first
    // These are a count of bytes seen for each preceding byte.
    std::vector<std::vector<int>> counts(256);
    for (auto&& v: counts) v.resize(256);
    int precedingByte = EOS;
    for (auto&& entry : script)
    {
        for (auto&& thisByte : entry.data)
        {
            ++counts[precedingByte][thisByte];
            precedingByte = thisByte;
        }
    }

    // Build trees
    for (int precedingSymbol = 0; precedingSymbol < 256; precedingSymbol++)
    {
        // Make a leaf node for each symbol
        std::vector<Tree::Node*> newNodes;
        for (int symbol = 0; symbol < 256; symbol++)
        {
            const int count = counts[precedingSymbol][symbol];
            if (count == 0)
            {
                continue;
            }
            newNodes.push_back(new Tree::Node(symbol, count));
        }

        // Assemble into a tree
        trees.emplace_back(precedingSymbol, newNodes);
    }
  
    // Remove any trailing "empty trees" (i.e. unused symbols)
    while (trees.back().isEmpty())
    {
        trees.pop_back();
    }

    int treesSize = 0;
    std::ofstream o(treeFilename);
    o << "TreeVector:\n.dw";
    // Labels
    for (auto&& tree : trees)
    {
        if (tree.isEmpty())
        {
            o << " $ffff";
        }
        else
        {
            o << ' ' << tree.getName();
        }
        treesSize += 2;
    }
    o << "\n";
    // Data
    for (std::size_t i = 0; i < trees.size(); ++i)
    {
        auto& tree = trees[i];
        if (tree.isEmpty())
        {
            continue;
        }
        o << "; Dictionary elements that can follow element $" << std::hex << i << "\n";
        treesSize += tree.symbols(o);
        o << tree.getName() << ": ; Binary tree structure for the above\n";
        treesSize += tree.structure(o);
    }
    std::cout << "Huffman trees take " << std::dec << treesSize << " bytes\n";
}

void EmitScript(const std::string& scriptFilename, const std::string& patchFilename, const std::vector<Tree>& trees, const std::vector<ScriptItem>& script)
{
    std::ofstream scriptFile(scriptFilename);
    scriptFile << "; Script entries, Huffman compressed\n";

    std::ofstream patchFile(patchFilename);
    patchFile << "; Patches to point at new script entries\n";

    int scriptSize = 0;
    for (auto&& entry : script)
    {
        scriptFile << '\n' << entry.label << ":\n/*" << entry.text << "*/\n.db";

        // Starting tree number
        int previousSymbol = EOS;

        // Scope for BitWriter
        BitWriter bw(scriptFile);
        // Construct each Huffman code
        for (auto&& symbol : entry.data)
        {
            // find in tree
            auto codeword = trees[previousSymbol].getCodeword(symbol);

            // Write out created codeword
            for (auto&& value : codeword)
            {
                bw.add(value);
            }

            // Use new symbol as fresh index
            previousSymbol = symbol;
        }

        for (auto && offset : entry.offsets)
        {
            patchFile << " PatchW $" << std::hex << std::setw(4) << std::setfill('0') << offset + 1 << ' ' << entry.label << '\n';
        }

        scriptSize += bw.getBytes();
    }
    std::cout << "Huffman compressed script is " << std::dec << scriptSize << " bytes\n";
}


void Huffman_Compress(const std::string& scriptFilename, const std::string& patchFilename, const std::string& treeFilename, const std::vector<ScriptItem>& script)
{
    std::vector<Tree> trees;
    BuildHuffmanTree(treeFilename, trees, script);
    EmitScript(scriptFilename, patchFilename, trees, script);
}
