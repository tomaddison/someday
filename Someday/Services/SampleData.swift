// DEBUG-only demo dataset.
import Foundation
import SwiftData

enum SampleData {
    private struct SeedMoment {
        let daysAgo: Int
        let hour: Int
        let minute: Int
        let note: String
        let somedays: [SomedayItem]
    }

    static func populate(into context: ModelContext) {
        clearAll(from: context)

        let user = User(
            northStar: "Be a force of kindness in the world",
            onboardingCompleted: true
        )
        context.insert(user)

        let family = SomedayItem(
            title: "Keep in touch with family",
            colorHex: "#F2BFC0",
            why: "They're the shape of home. Distance makes that easy to forget.",
            sortOrder: 0
        )
        let piano = SomedayItem(
            title: "Make time for playing the piano",
            colorHex: "#CFB8E9",
            why: "An hour at the keys is an hour that belongs to me.",
            sortOrder: 1
        )
        let creative = SomedayItem(
            title: "Build something creative",
            colorHex: "#F8C4A4",
            why: "Making things is how I stay curious.",
            sortOrder: 2
        )
        let outdoors = SomedayItem(
            title: "Spend time outdoors",
            colorHex: "#CFE2A4",
            why: "The best version of me starts on a walk.",
            sortOrder: 3
        )
        let kindness = SomedayItem(
            title: "Be kind to more strangers",
            colorHex: "#EDE4A1",
            why: "Small kindnesses compound. This is the North Star made small.",
            sortOrder: 4
        )

        let somedays = [family, piano, creative, outdoors, kindness]
        somedays.forEach { context.insert($0) }

        var entries: [SeedMoment] = []

        // Keep in touch with family
        entries.append(SeedMoment(daysAgo: 2, hour: 8, minute: 15,
            note: "Called Mum on the walk to work. She told me about the slugs that have taken over her hostas and laughed for about three minutes straight. I'd forgotten how much I miss her laugh on a normal weekday.",
            somedays: [family]))
        entries.append(SeedMoment(daysAgo: 9, hour: 19, minute: 30,
            note: "Family dinner at Mum's. Nephew showed me his Lego X-wing with absolute solemnity. He'd hidden a tiny figure in the engine block 'because then he's safe.' I've been thinking about that all week.",
            somedays: [family]))
        entries.append(SeedMoment(daysAgo: 16, hour: 11, minute: 0,
            note: "Video call with Sarah to help her with her CV. She's always been the writer in the family but she's suddenly shy about her own life. We rewrote the summary three times and she cried a bit and then we laughed.",
            somedays: [family]))
        entries.append(SeedMoment(daysAgo: 27, hour: 20, minute: 45,
            note: "Wrote Nan a proper letter. First one in years. Told her about the garden and about the piano and about how I think of her whenever I see hellebores. Posted it before I could overthink it.",
            somedays: [family]))
        entries.append(SeedMoment(daysAgo: 41, hour: 14, minute: 20,
            note: "Long drive to the coast with Dad, windows down. We barely talked for the first hour and it was perfect. Fish and chips on a bench, wind in our eyes. He told me something about Grandad I'd never heard before.",
            somedays: [family, outdoors]))
        entries.append(SeedMoment(daysAgo: 54, hour: 10, minute: 15,
            note: "Walk through Epping with Dad, just the two of us. He pointed out birds I couldn't see. I've decided I want to get better at naming things I look at every day.",
            somedays: [family, outdoors]))

        // Make time for playing the piano
        entries.append(SeedMoment(daysAgo: 1, hour: 22, minute: 10,
            note: "Sat down at the piano after dinner for the first time in weeks. Played Debussy's first Arabesque badly and loved every second. My hands remember more than I give them credit for.",
            somedays: [piano]))
        entries.append(SeedMoment(daysAgo: 6, hour: 21, minute: 0,
            note: "Got through the first page of 'Comptine d'un autre été' cleanly. It's a small thing but I've wanted to play this piece since I was seventeen.",
            somedays: [piano]))
        entries.append(SeedMoment(daysAgo: 12, hour: 23, minute: 5,
            note: "Improvised for twenty minutes after dinner. Nothing resolved, all mood, lots of sevenths. Didn't record it and I don't regret that - it was only for that room, that night.",
            somedays: [piano]))
        entries.append(SeedMoment(daysAgo: 20, hour: 20, minute: 30,
            note: "Recorded myself playing and made myself listen back. Excruciating. But I could hear exactly what I need to work on - my left hand is lazy and I rush the quiet bits.",
            somedays: [piano]))
        entries.append(SeedMoment(daysAgo: 33, hour: 19, minute: 45,
            note: "Played for an hour without looking at my phone once. The cat sat on the bench next to me. I forgot what time it was in the good way.",
            somedays: [piano]))
        entries.append(SeedMoment(daysAgo: 49, hour: 22, minute: 30,
            note: "Wrote a short melody I think I might actually keep. Four bars, nothing clever, but it has a shape. Wrote it down on the back of an envelope like some kind of old-timer.",
            somedays: [piano]))

        // Build something creative
        entries.append(SeedMoment(daysAgo: 3, hour: 13, minute: 45,
            note: "Started a scrappy notebook of half-formed ideas - projects, stories, things to make, questions I want to sit with. Nothing has to become anything. The point is just to catch them before they drift off.",
            somedays: [creative]))
        entries.append(SeedMoment(daysAgo: 11, hour: 15, minute: 20,
            note: "Made a clay dish at the studio today. It's a bit wonky and the glaze pooled on one side but it's honest and it's mine. Going to eat breakfast out of it tomorrow.",
            somedays: [creative]))
        entries.append(SeedMoment(daysAgo: 22, hour: 10, minute: 30,
            note: "Spent all Saturday shooting film on the old Pentax around Borough Market. Two rolls. Half will be unusable and I'm strangely looking forward to that - I've missed the not-knowing.",
            somedays: [creative]))
        entries.append(SeedMoment(daysAgo: 30, hour: 21, minute: 15,
            note: "Rewrote the first page of the story I abandoned last winter. Kept almost nothing. The bones are better than I remembered. I think I was just scared of it.",
            somedays: [creative]))
        entries.append(SeedMoment(daysAgo: 44, hour: 19, minute: 0,
            note: "Stained glass class - cut my first truly clean edge tonight. The teacher said 'good' without looking up, which from her is basically a standing ovation.",
            somedays: [creative]))
        entries.append(SeedMoment(daysAgo: 58, hour: 16, minute: 30,
            note: "Built a rough single-page site for the photo series. Nothing public yet. But seeing them laid out in a grid made me realise there's actually something here.",
            somedays: [creative]))

        // Spend time outdoors
        entries.append(SeedMoment(daysAgo: 0, hour: 7, minute: 30,
            note: "Run through the park before the day started. Everything was frosted and the low sun caught the spider webs between the railings. I don't think I saw another person for twenty minutes.",
            somedays: [outdoors]))
        entries.append(SeedMoment(daysAgo: 5, hour: 11, minute: 45,
            note: "Long walk across Hampstead Heath with a coffee and absolutely no agenda. Sat on a bench near the ponds for almost an hour. Didn't check my phone once, which is apparently still a notable achievement.",
            somedays: [outdoors]))
        entries.append(SeedMoment(daysAgo: 15, hour: 9, minute: 0,
            note: "Cycled to the coast with Dan. Forty miles, both of us gassed by the end, arms aching from the headwind. Ate chips on the pebbles. Best Saturday I've had in months.",
            somedays: [outdoors]))
        entries.append(SeedMoment(daysAgo: 25, hour: 17, minute: 30,
            note: "Sat on the hill behind the house reading until the light went. Came back with grass all over my jumper and a head that felt about fifty percent quieter than when I left.",
            somedays: [outdoors]))
        entries.append(SeedMoment(daysAgo: 38, hour: 8, minute: 45,
            note: "Walked to the bakery instead of driving. Ten minutes there, ten minutes back. Such a small swap. But it turned a chore into the nicest bit of the morning.",
            somedays: [outdoors]))
        entries.append(SeedMoment(daysAgo: 52, hour: 16, minute: 15,
            note: "Park run with Jess. Slower than I wanted but we talked the whole way and it turns out that's the whole point.",
            somedays: [outdoors]))

        // Be kind to more strangers
        entries.append(SeedMoment(daysAgo: 1, hour: 9, minute: 20,
            note: "Paid for the person behind me in the coffee queue. Felt silly for about four seconds, then didn't. She looked genuinely surprised - in a good way. Tiny cost, absurdly good feeling.",
            somedays: [kindness]))
        entries.append(SeedMoment(daysAgo: 8, hour: 18, minute: 0,
            note: "Helped an older woman carry her shopping up the tube steps at Angel. She apologised about five times for 'being a bother.' I keep thinking about how many people must walk past her every day.",
            somedays: [kindness]))
        entries.append(SeedMoment(daysAgo: 17, hour: 20, minute: 30,
            note: "Left a generous tip and wrote the server's name in the note. It's such a small thing and I'd been meaning to start doing it for ages. Easy once you've done it once.",
            somedays: [kindness]))
        entries.append(SeedMoment(daysAgo: 28, hour: 17, minute: 45,
            note: "Gave up my seat on the Overground to someone who looked absolutely wiped. She nearly cried. I think she'd had a much harder day than I'd noticed. I want to be the kind of person who notices sooner.",
            somedays: [kindness]))
        entries.append(SeedMoment(daysAgo: 40, hour: 12, minute: 0,
            note: "Held the door open at the post office for much longer than necessary - there was just a steady stream of people. One man laughed and said 'you're committed.' It felt like a small good joke shared with a town.",
            somedays: [kindness]))
        entries.append(SeedMoment(daysAgo: 55, hour: 21, minute: 30,
            note: "Sent a genuine thank-you email to a stranger whose newsletter I've been reading for six years. Kept it short. She replied within an hour. Both of us probably needed that more than we realised.",
            somedays: [kindness]))

        let calendar = Calendar.current
        let now = Date()
        for entry in entries {
            guard let day = calendar.date(byAdding: .day, value: -entry.daysAgo, to: now),
                  let when = calendar.date(
                    bySettingHour: entry.hour,
                    minute: entry.minute,
                    second: 0,
                    of: day
                  )
            else { continue }

            let moment = Moment(note: entry.note, createdAt: when, somedays: entry.somedays)
            context.insert(moment)
        }

        // Align each Someday's lastEngagedAt with its most recent Moment so aging visuals reflect the seed data.
        for someday in somedays {
            if let latest = someday.moments.map(\.createdAt).max() {
                someday.lastEngagedAt = latest
            }
        }
    }

    static func clearAll(from context: ModelContext) {
        if let moments = try? context.fetch(FetchDescriptor<Moment>()) {
            moments.forEach { context.delete($0) }
        }
        if let somedays = try? context.fetch(FetchDescriptor<SomedayItem>()) {
            somedays.forEach { context.delete($0) }
        }
        if let users = try? context.fetch(FetchDescriptor<User>()) {
            users.forEach { context.delete($0) }
        }
    }
}
