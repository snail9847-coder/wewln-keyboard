import Foundation
func typed(_ input: String) -> String {
    var result = ""
    for character in input {
        result += Spacing.insertion(String(character), before: result)
    }
    return result
}
assert(typed("привет как дела") == "п р и в е т   к а к   д е л а")
assert(typed("Ёж 12!") == "Ё ж   1 2!")
assert(typed("да\nнет") == "д а\nн е т")
assert(typed("привет, мир") == "п р и в е т,   м и р")
assert(Spacing.deleteCount(before: "п р") == 2)
assert(Spacing.deleteCount(before: "п   р") == 1)
assert(Spacing.deleteCount(before: "п   ") == 3)
assert(Spacing.deleteCount(before: "п") == 1)
print("Spacing tests passed")
