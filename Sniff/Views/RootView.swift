import SwiftUI
import SwiftData
import Charts
import PhotosUI

struct RootView: View {
    @Query(sort: \PetProfile.createdAt) private var pets: [PetProfile]
    var showPersistenceWarning = false
    @State private var showingLaunchSurface = true
    var body: some View {
        ZStack {
            Color.sniffPaper.ignoresSafeArea()
            if pets.isEmpty { WelcomeView(ownerUID: "local").transition(routeTransition) }
            else { MainTabView(ownerUID: nil).transition(routeTransition) }
            if showingLaunchSurface { LaunchSurface().transition(.opacity) }
        }
            .tint(.sniffBlue).foregroundStyle(Color.sniffInk).fontDesign(.rounded)
            .animation(.spring(response: 0.48, dampingFraction: 0.84), value: pets.count)
            .safeAreaInset(edge: .top, spacing: 0) {
                if showPersistenceWarning && !showingLaunchSurface {
                    Label("Pet data couldn’t be opened. Running a temporary safe session.", systemImage: "exclamationmark.triangle.fill")
                        .font(.caption.bold()).foregroundStyle(.white).padding(10).frame(maxWidth: .infinity).background(Color.sniffCoral)
                }
            }
            .task {
                try? await Task.sleep(for: .milliseconds(720))
                withAnimation(.easeOut(duration: 0.28)) { showingLaunchSurface = false }
            }
    }
    private var routeTransition: AnyTransition { .opacity.combined(with: .scale(scale: 0.97)) }
}

struct LaunchSurface: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    var body: some View {
        ZStack {
            PetCareBackdrop()
            VStack(spacing: 20) {
                ZStack {
                    Circle().fill(Color.sniffLavender).frame(width: 116, height: 116)
                    Image(systemName: "cat.fill").font(.system(size: 58, weight: .semibold)).foregroundStyle(Color.sniffPurple)
                        .phaseAnimator(reduceMotion ? [false] : [false, true]) { content, hop in
                            content.offset(y: hop ? -5 : 3).rotationEffect(.degrees(hop ? 2 : -2))
                        } animation: { _ in .spring(duration: 0.72, bounce: 0.42) }
                    ForEach(0..<3) { index in
                        Image(systemName: "pawprint.fill")
                            .font(.system(size: 17, weight: .bold))
                            .foregroundStyle([Color.sniffCoral, .sniffAqua, .sniffMango][index])
                            .offset(x: [-58, 0, 58][index], y: [-42, -67, -42][index])
                            .phaseAnimator(reduceMotion ? [false] : [false, true]) { content, active in
                                content.scaleEffect(active ? 1.08 : 0.72).opacity(active ? 1 : 0.42)
                            } animation: { _ in .easeInOut(duration: 0.56).delay(Double(index) * 0.11) }
                    }
                }.frame(height: 150)
                Text("PAWPRINT").font(.system(size: 15, weight: .heavy, design: .rounded)).tracking(2.4).foregroundStyle(Color.sniffPurple)
                Text("Finding a little adventure…").font(.system(.headline, design: .rounded, weight: .semibold)).foregroundStyle(Color.sniffMuted)
                Capsule().fill(Color.sniffLine).frame(width: 142, height: 8)
                    .overlay(alignment: .leading) {
                        Capsule().fill(LinearGradient(colors: [.sniffPurple, .sniffBerry, .sniffCoral], startPoint: .leading, endPoint: .trailing))
                            .frame(width: 62, height: 8)
                            .phaseAnimator(reduceMotion ? [false] : [false, true]) { content, moving in content.offset(x: moving ? 78 : 2) } animation: { _ in .easeInOut(duration: 0.7) }
                    }.clipShape(Capsule())
            }.padding(30)
        }.ignoresSafeArea().accessibilityElement(children: .combine).accessibilityLabel("Pawprint is opening")
    }
}


struct FancyField: View {
    let icon: String; let placeholder: String; @Binding var text: String
    var contentType: UITextContentType? = nil
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon).foregroundStyle(Color.sniffMint).frame(width: 22)
            TextField(placeholder, text: $text).textContentType(contentType).textInputAutocapitalization(contentType == .emailAddress ? .never : .words).autocorrectionDisabled(contentType == .emailAddress)
        }.padding(16).background(.white, in: RoundedRectangle(cornerRadius: 18)).overlay { RoundedRectangle(cornerRadius: 18).stroke(Color.sniffLine) }.shadow(color: Color.sniffMint.opacity(0.07), radius: 12, y: 6)
    }
}

struct WelcomeView: View {
    let ownerUID: String
    @State private var onboarding = false
    var body: some View {
        ZStack {
            Color.sniffPaper.ignoresSafeArea()
            VStack(alignment: .leading, spacing: 28) {
                Spacer()
                PlayfulBrandMark(size: 88)
                VStack(alignment: .leading, spacing: 8) {
                    Text("PAWPRINT").font(.caption.bold()).tracking(2.2).foregroundStyle(Color.sniffBlue)
                    Text("They leave a mark.").font(.system(size: 42, weight: .bold, design: .rounded))
                }
                Text("One simple activity a day, made for your pet.")
                    .font(.title3).foregroundStyle(.secondary)
                VStack(alignment: .leading, spacing: 12) {
                    Label("One activity, chosen for you", systemImage: "sparkles")
                    Label("Build a playful rhythm, at your pace", systemImage: "calendar")
                    Label("Bonding, not busywork", systemImage: "heart")
                }.font(.headline).foregroundStyle(Color.sniffInk.opacity(0.88))
                Button("Set up their profile") { onboarding = true }.buttonStyle(PrimaryButtonStyle())
                Spacer()
            }.padding(28)
        }.fullScreenCover(isPresented: $onboarding) { OnboardingView(ownerUID: ownerUID) }
    }
}

struct OnboardingView: View {
    var accountID: UUID? = nil
    var ownerUID: String? = nil
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @AppStorage("petDraft.step") private var step = 0
    @AppStorage("petDraft.species") private var speciesRaw = Species.dog.rawValue
    @AppStorage("petDraft.name") private var name = ""
    @AppStorage("petDraft.ageYears") private var ageYears = 3.0
    @AppStorage("petDraft.weightPounds") private var weightPounds = 30.0
    @AppStorage("petDraft.playDrive") private var playDrive = 2.0
    @AppStorage("petDraft.stamina") private var stamina = 2.0
    @AppStorage("petDraft.settleEase") private var settleEase = 2.0
    @AppStorage("petDraft.limitations") private var limitationsDraft = ""
    @AppStorage("petDraft.materials") private var materialsDraft = "towel,cardboard"
    @AppStorage("petDraft.dayPeriods") private var dayPeriodsDraft = ""
    @AppStorage("petDraft.foodMotivation") private var foodMotivationRaw = FoodMotivation.medium.rawValue
    @AppStorage("petDraft.socialStyle") private var socialStyleRaw = SocialStyle.nearby.rawValue
    @AppStorage("petDraft.noiseSensitive") private var noiseSensitive = false
    @AppStorage("petDraft.mealsPerDay") private var mealsPerDay = 2
    @AppStorage("petDraft.firstMealHour") private var firstMealHour = 8
    @AppStorage("petDraft.lastMealHour") private var lastMealHour = 18
    @AppStorage("petDraft.dietStyle") private var dietStyleRaw = DietStyle.mixed.rawValue
    @AppStorage("petDraft.foodEnrichmentAllowed") private var foodEnrichmentAllowed = true
    @AppStorage("petDraft.hasSnacks") private var hasSnacks = true
    @AppStorage("petDraft.snacksPerDay") private var snacksPerDay = 2
    @AppStorage("petDraft.snackKinds") private var snackKinds = ""
    @AppStorage("petDraft.wakeHour") private var wakeHour = 7
    @AppStorage("petDraft.sleepHour") private var sleepHour = 22
    @AppStorage("petDraft.hoursAloneDaily") private var hoursAloneDaily = 2.0
    @AppStorage("petDraft.livingStyle") private var livingStyleRaw = LivingStyle.indoors.rawValue
    @State private var limitations: Set<Limitation> = []
    @State private var materials: Set<Material> = [.towel, .cardboard]
    @State private var dayPeriods: Set<DayPeriod> = []
    @State private var scanningBreed = false
    private var species: Species { Species(rawValue: speciesRaw) ?? .dog }
    private var totalSteps: Int { 8 }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.sniffPaper.ignoresSafeArea()
                VStack(spacing: 0) {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 22) {
                            onboardingHeader
                            stepContent
                        }.padding(24)
                    }
                    onboardingFooter
                }
            }
                .navigationTitle("Let’s get set up").navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button { goBack() } label: { Image(systemName: "chevron.left") }
                            .accessibilityLabel(step == 0 ? "Back to welcome" : "Previous step")
                    }
                }
                .onAppear(perform: restoreDraftCollections)
                .onChange(of: limitations) { _, value in limitationsDraft = value.map(\.rawValue).sorted().joined(separator: ",") }
                .onChange(of: materials) { _, value in materialsDraft = value.map(\.rawValue).sorted().joined(separator: ",") }
                .onChange(of: dayPeriods) { _, value in dayPeriodsDraft = value.map(\.rawValue).sorted().joined(separator: ",") }
                .sheet(isPresented: $scanningBreed) { BreedScanOnboardingPlaceholder(species: species) }
        }
    }

    private var onboardingHeader: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 10) {
                Image("BrandMark").resizable().scaledToFit().frame(width: 42, height: 42).clipShape(RoundedRectangle(cornerRadius: 10))
                VStack(alignment: .leading, spacing: 2) {
                    Text("PAWPRINT").font(.caption.bold()).tracking(1.6).foregroundStyle(Color.sniffBlue)
                    Text("Step \(step + 1) of \(totalSteps)").font(.caption).foregroundStyle(.secondary)
                }
            }
            ProgressView(value: Double(step + 1), total: Double(totalSteps)).tint(Color.sniffBlue)
        }
    }

    @ViewBuilder private var stepContent: some View {
        switch step {
        case 0: speciesStep
        case 1: identityStep
        case 2: ageAndSizeStep
        case 3: energyStep
        case 4: rhythmStep
        case 5: routineStep
        case 6: safetyStep
        default: materialsStep
        }
    }

    @ViewBuilder private var onboardingFooter: some View {
        if step > 0 {
            VStack {
                Button(action: advance) {
                    HStack {
                        Text(step == totalSteps - 1 ? "Find today’s activity" : "Continue")
                        Spacer()
                        Image(systemName: "arrow.right")
                    }
                }
                .buttonStyle(PrimaryButtonStyle())
                .disabled(step == 1 && name.trimmingCharacters(in: .whitespaces).isEmpty)
            }
            .padding(.horizontal, 24).padding(.vertical, 16)
            .background(.white.opacity(0.96))
            .overlay(alignment: .top) { Divider() }
        }
    }

    private var speciesStep: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text("Who’s joining the fun?").font(.largeTitle.bold()).lineLimit(2).minimumScaleFactor(0.82)
            HStack(spacing: 42) {
                MiniPetChoice(species: .dog) { selectSpecies(.dog) }
                MiniPetChoice(species: .cat) { selectSpecies(.cat) }
            }
            .frame(maxWidth: .infinity).padding(.top, 24)
        }
    }
    private var identityStep: some View {
        FormSection(title: "About your sidekick") {
            PetFace(species: species, size: 88)
                .frame(maxWidth: .infinity)
            LabeledControl(title: "What’s their name?") {
                HStack(spacing: 11) {
                    Image(systemName: "pawprint.fill").foregroundStyle(Color.sniffBlue)
                    TextField("Their name", text: $name).textContentType(.name)
                }
                .padding(16).background(.white, in: RoundedRectangle(cornerRadius: 18))
                .overlay { RoundedRectangle(cornerRadius: 18).stroke(Color.sniffLine) }
                .shadow(color: Color.sniffBlue.opacity(0.08), radius: 12, y: 6)
            }
            Button { scanningBreed = true } label: {
                HStack(spacing: 12) {
                    Image(systemName: "viewfinder").font(.title2).foregroundStyle(Color.sniffPurple)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Scan breed or type").font(.headline)
                        Text("Optional AI add-on · coming later").font(.caption).foregroundStyle(.secondary)
                    }
                    Spacer(); Text("Preview").font(.caption.bold()).foregroundStyle(Color.sniffPurple)
                }.padding(15).background(Color.sniffLavender, in: RoundedRectangle(cornerRadius: 20))
            }.buttonStyle(.plain)
        }
    }
    private var ageAndSizeStep: some View {
        FormSection(title: "The useful basics") {
            Text("Exact answers help us avoid activities that are too easy, tiring, or awkward.").foregroundStyle(.secondary)
            LabeledControl(title: "How old is \(name.isEmpty ? "your pet" : name)?", hint: ageLabel) {
                Slider(value: $ageYears, in: 0.25...22, step: 0.25).tint(.sniffPurple)
                HStack { Text("3 months"); Spacer(); Text("22 years") }.font(.caption2).foregroundStyle(.secondary)
            }.padding().background(.white, in: RoundedRectangle(cornerRadius: 20))
            LabeledControl(title: "About how much do they weigh?", hint: "\(Int(weightPounds.rounded())) lb · \(sizeBand.rawValue.capitalized) for a \(species.rawValue)") {
                PetSizeIndicator(species: species, weight: weightPounds, maximum: weightMaximum)
                Slider(value: $weightPounds, in: 2...weightMaximum, step: 1).tint(.sniffMint)
                HStack { Text("Tiny"); Spacer(); Text("Big friend") }.font(.caption2).foregroundStyle(.secondary)
            }.padding().background(.white, in: RoundedRectangle(cornerRadius: 20))
        }
    }
    private var energyStep: some View {
        FormSection(title: "How does \(name.isEmpty ? "your pet" : name) move through a day?") {
            Text("Three quick observations are more useful than one vague ‘vibe.’ Your best guess is enough.").foregroundStyle(.secondary)
            EnergyQuestion(title: "How often do they initiate play?", low: "Rarely", high: "All the time", value: $playDrive, color: .sniffCoral)
            EnergyQuestion(title: "How long can they stay happily active?", low: "A few minutes", high: "A long session", value: $stamina, color: .sniffMint)
            EnergyQuestion(title: "How easily do they settle afterward?", low: "Needs help", high: "Very easily", value: $settleEase, color: .sniffPurple)
            HStack(spacing: 10) {
                Image(systemName: energyLevel == .high ? "hare.fill" : energyLevel == .low ? "tortoise.fill" : "pawprint.fill").foregroundStyle(.white)
                Text("We’ll start \(energyLevel.rawValue), then learn from what \(name.isEmpty ? "they" : name) actually enjoys.").font(.subheadline.bold())
            }.padding().frame(maxWidth: .infinity, alignment: .leading).background(Color.sniffBlue, in: RoundedRectangle(cornerRadius: 18)).foregroundStyle(.white)
        }
    }
    private var safetyStep: some View {
        FormSection(title: "Anything to skip?") {
            Text("Pick anything that might make play less fun. We’ll choose around it.").foregroundStyle(.secondary)
            ChoiceGrid(values: Limitation.allCases, selected: $limitations) { $0.label }
        }
    }
    private var rhythmStep: some View {
        FormSection(title: "What makes a good moment for \(name.isEmpty ? "your pet" : name)?") {
            Text("These are starting clues, not permanent labels. Today’s mood and your available time can always override them.").foregroundStyle(.secondary)
            Text("When are they usually most open to an activity?").font(.headline)
            ChoiceGrid(values: DayPeriod.allCases, selected: $dayPeriods) { $0.label }
            LabeledControl(title: "How motivating is food?") {
                Picker("Food motivation", selection: $foodMotivationRaw) { ForEach(FoodMotivation.allCases) { Text($0.label).tag($0.rawValue) } }
                    .pickerStyle(.segmented)
            }.padding().background(.white, in: RoundedRectangle(cornerRadius: 20))
            LabeledControl(title: "How do they prefer your company?") {
                Picker("Social style", selection: $socialStyleRaw) { ForEach(SocialStyle.allCases) { Text($0.label).tag($0.rawValue) } }
                    .pickerStyle(.segmented)
            }.padding().background(.white, in: RoundedRectangle(cornerRadius: 20))
            Toggle("Sensitive to sudden sounds", isOn: $noiseSensitive).padding().background(.white, in: RoundedRectangle(cornerRadius: 20))
        }
    }
    private var routineStep: some View {
        FormSection(title: "Tell us about a normal day") {
            Text("Routine helps us avoid awkward timing and suggest activities that fit real life.").foregroundStyle(.secondary)
            Stepper("\(mealsPerDay) meals each day", value: $mealsPerDay, in: 1...6)
                .padding().background(.white, in: RoundedRectangle(cornerRadius: 20))
            HStack {
                hourPicker("First meal", selection: $firstMealHour)
                if mealsPerDay > 1 { hourPicker("Last meal", selection: $lastMealHour) }
            }
            LabeledControl(title: "What do they usually eat?") {
                Picker("Diet", selection: $dietStyleRaw) { ForEach(DietStyle.allCases) { Text($0.label).tag($0.rawValue) } }.pickerStyle(.menu)
            }.padding().background(.white, in: RoundedRectangle(cornerRadius: 20))
            Toggle("Food can be used in enrichment", isOn: $foodEnrichmentAllowed)
                .padding().background(.white, in: RoundedRectangle(cornerRadius: 20))
            Toggle("They have snacks or treats", isOn: $hasSnacks)
                .padding().background(.white, in: RoundedRectangle(cornerRadius: 20))
            if hasSnacks {
                Stepper("About \(snacksPerDay) snack moments a day", value: $snacksPerDay, in: 0...8)
                    .padding().background(.white, in: RoundedRectangle(cornerRadius: 20))
                FancyField(icon: "carrot.fill", placeholder: "What snacks do they have?", text: $snackKinds)
            }
            HStack {
                hourPicker("Usually awake", selection: $wakeHour)
                hourPicker("Usually settles", selection: $sleepHour)
            }
            LabeledControl(title: "Time alone on a usual day", hint: String(format: "%.1f hours", hoursAloneDaily)) {
                Slider(value: $hoursAloneDaily, in: 0...12, step: 0.5)
            }.padding().background(.white, in: RoundedRectangle(cornerRadius: 20))
            LabeledControl(title: "Where do they spend their time?") {
                Picker("Living style", selection: $livingStyleRaw) { ForEach(LivingStyle.allCases) { Text($0.label).tag($0.rawValue) } }.pickerStyle(.segmented)
            }.padding().background(.white, in: RoundedRectangle(cornerRadius: 20))
        }
    }
    private func hourPicker(_ title: String, selection: Binding<Int>) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title).font(.caption.bold()).foregroundStyle(.secondary)
            Picker(title, selection: selection) {
                ForEach(0..<24, id: \.self) { hour in Text(hourLabel(hour)).tag(hour) }
            }.pickerStyle(.menu)
        }.frame(maxWidth: .infinity, alignment: .leading).padding().background(.white, in: RoundedRectangle(cornerRadius: 20))
    }
    private func hourLabel(_ hour: Int) -> String {
        let suffix = hour < 12 ? "AM" : "PM"; let display = hour % 12 == 0 ? 12 : hour % 12
        return "\(display):00 \(suffix)"
    }
    private var materialsStep: some View {
        FormSection(title: "What can we play with?") {
            Text("Pick what’s already around. No shopping trip required.").foregroundStyle(.secondary)
            ForEach(MaterialGroup.allCases) { group in
                let values = Material.allCases.filter { $0.group == group && $0.fits(species) }.prefix(9)
                if !values.isEmpty {
                    Text(group.rawValue).font(.headline)
                    ChoiceGrid(values: Array(values), selected: $materials) { $0.label }
                }
            }
        }
    }
    private func advance() {
        if step < totalSteps - 1 { withAnimation { step += 1 } }
        else {
            let pet = PetProfile(name: name.trimmingCharacters(in: .whitespaces), species: species, age: ageBand, size: sizeBand, energy: energyLevel, exactAgeYears: ageYears, weightPounds: weightPounds, limitations: limitations, materials: materials, accountID: accountID, ownerUID: ownerUID)
            pet.preferredDayPeriodRaws = dayPeriods.map(\.rawValue).sorted(); pet.foodMotivationRaw = foodMotivationRaw
            pet.socialStyleRaw = socialStyleRaw; pet.noiseSensitive = noiseSensitive; modelContext.insert(pet)
            pet.mealsPerDay = mealsPerDay; pet.firstMealHour = firstMealHour; pet.lastMealHour = mealsPerDay > 1 ? lastMealHour : firstMealHour
            pet.dietStyleRaw = dietStyleRaw; pet.foodEnrichmentAllowed = foodEnrichmentAllowed; pet.wakeHour = wakeHour; pet.sleepHour = sleepHour
            pet.hasSnacks = hasSnacks; pet.snacksPerDay = hasSnacks ? snacksPerDay : 0; pet.snackKinds = hasSnacks ? snackKinds.trimmingCharacters(in: .whitespacesAndNewlines) : ""
            pet.hoursAloneDaily = hoursAloneDaily; pet.livingStyleRaw = livingStyleRaw
            try? modelContext.save(); clearDraft(); dismiss()
        }
    }
    private func goBack() {
        if step > 0 { withAnimation { step -= 1 } }
        else { dismiss() }
    }
    private func selectSpecies(_ selection: Species) {
        speciesRaw = selection.rawValue
        weightPounds = selection == .cat ? 10 : 30
        withAnimation(.spring(response: 0.42, dampingFraction: 0.78)) { step = 1 }
    }
    private var ageLabel: String { ageYears < 2 ? "\(Int((ageYears * 12).rounded())) months old" : String(format: "%.1f years old", ageYears) }
    private var ageBand: AgeBand { ageYears < 1.5 ? .young : ageYears >= (species == .cat ? 11 : 8) ? .senior : .adult }
    private var weightMaximum: Double { species == .cat ? 30 : 180 }
    private var sizeBand: SizeBand {
        if species == .cat { return weightPounds < 8 ? .small : weightPounds < 15 ? .medium : .large }
        return weightPounds < 20 ? .small : weightPounds < 60 ? .medium : .large
    }
    private var energyLevel: EnergyLevel {
        let score = (playDrive + stamina + (4 - settleEase)) / 3
        return score < 1.5 ? .low : score > 2.7 ? .high : .medium
    }
    private func restoreDraftCollections() {
        limitations = Set(limitationsDraft.split(separator: ",").compactMap { Limitation(rawValue: String($0)) })
        materials = Set(materialsDraft.split(separator: ",").compactMap { Material(rawValue: String($0)) })
        dayPeriods = Set(dayPeriodsDraft.split(separator: ",").compactMap { DayPeriod(rawValue: String($0)) })
        if materials.isEmpty { materials = [.towel, .cardboard] }
    }
    private func clearDraft() {
        step = 0; speciesRaw = Species.dog.rawValue; name = ""; ageYears = 3; weightPounds = 30
        playDrive = 2; stamina = 2; settleEase = 2; limitationsDraft = ""; materialsDraft = "towel,cardboard"; dayPeriodsDraft = ""
        foodMotivationRaw = FoodMotivation.medium.rawValue; socialStyleRaw = SocialStyle.nearby.rawValue; noiseSensitive = false
        mealsPerDay = 2; firstMealHour = 8; lastMealHour = 18; dietStyleRaw = DietStyle.mixed.rawValue; foodEnrichmentAllowed = true
        hasSnacks = true; snacksPerDay = 2; snackKinds = ""
        wakeHour = 7; sleepHour = 22; hoursAloneDaily = 2; livingStyleRaw = LivingStyle.indoors.rawValue
    }
}

struct EnergyQuestion: View {
    let title: String; let low: String; let high: String; @Binding var value: Double; let color: Color
    var body: some View {
        VStack(alignment: .leading, spacing: 9) {
            Text(title).font(.headline)
            Slider(value: $value, in: 0...4, step: 1).tint(color)
            HStack { Text(low); Spacer(); Text(high) }.font(.caption).foregroundStyle(.secondary)
        }.padding().background(.white, in: RoundedRectangle(cornerRadius: 20))
    }
}

struct PetSizeIndicator: View {
    let species: Species; let weight: Double; let maximum: Double
    var body: some View {
        HStack {
            Spacer()
            Image(systemName: species == .dog ? "dog.fill" : "cat.fill")
                .font(.system(size: 30 + 42 * weight / maximum, weight: .semibold))
                .foregroundStyle(Color.sniffMint)
                .frame(width: 90, height: 76, alignment: .bottom)
                .animation(.spring(response: 0.35, dampingFraction: 0.7), value: weight)
            Spacer()
        }
    }
}

struct BreedScanOnboardingPlaceholder: View {
    @Environment(\.dismiss) private var dismiss
    let species: Species
    var body: some View {
        NavigationStack {
            VStack(spacing: 22) {
                Spacer(); SelectedPetLogo(species: species)
                Text("Breed scan is coming later").font(.largeTitle.bold()).multilineTextAlignment(.center)
                Text("A future AI add-on could use a photo to suggest breed or type. You’ll always be able to correct it—and it won’t block setup.").font(.title3).foregroundStyle(.secondary).multilineTextAlignment(.center)
                Spacer(); Button("Continue setup") { dismiss() }.buttonStyle(PrimaryButtonStyle())
            }.padding(28).background(Color.sniffPaper)
        }
    }
}

struct MainTabView: View {
    let ownerUID: String?
    @Query(sort: \PetProfile.createdAt) private var pets: [PetProfile]
    @AppStorage("selectedPetID") private var selectedPetID = ""
    @State private var addingPet = false
    @State private var editingMaterials = false
    @State private var scanningBreed = false
    @State private var section: PawprintSection = .play
    private var accountPets: [PetProfile] {
        guard let ownerUID else { return pets }
        return pets.filter { $0.ownerUID == ownerUID }
    }
    private var pet: PetProfile? { accountPets.first { $0.id.uuidString == selectedPetID } ?? accountPets.first }
    var body: some View {
        Group {
            if let pet {
                ZStack {
                    Group {
                        switch section {
                        case .play: NavigationStack { TodayView(pet: pet, availablePets: accountPets, openCare: { section = .care }).toolbar { petToolbar(pet) } }
                        case .fetch: NavigationStack { FetchView(pet: pet).toolbar { petToolbar(pet) } }
                        case .care: NavigationStack { CareView(pet: pet).toolbar { petToolbar(pet) } }
                        }
                    }.id(section).transition(.opacity.combined(with: .scale(scale: 0.985)))
                }
                .id("\(pet.id)-\(section.rawValue)")
                .animation(.easeInOut(duration: 0.24), value: section)
                .safeAreaInset(edge: .bottom, spacing: 0) { PawprintTabBar(selection: $section) }
            }
        }.onAppear { if !accountPets.contains(where: { $0.id.uuidString == selectedPetID }) { selectedPetID = accountPets.first?.id.uuidString ?? "" } }
            .fullScreenCover(isPresented: $addingPet) { OnboardingView(ownerUID: ownerUID) }
            .sheet(isPresented: $editingMaterials) { if let pet { MaterialEditorView(pet: pet) } }
            .sheet(isPresented: $scanningBreed) { if let pet { BreedScanPlaceholder(pet: pet) } }
    }
    @ToolbarContentBuilder private func petToolbar(_ current: PetProfile) -> some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Menu {
                ForEach(accountPets) { pet in
                    Button { selectedPetID = pet.id.uuidString } label: {
                        Label(pet.name, systemImage: pet.id == current.id ? "checkmark.circle.fill" : (pet.species == .cat ? "cat.fill" : "dog.fill"))
                    }
                }
                Divider()
                Button { addingPet = true } label: {
                    Label("Add pet", systemImage: "plus.circle.fill")
                }
            } label: {
                HStack(spacing: 7) {
                    PetAvatar(pet: current, size: 28, animated: false)
                    Text(current.name).font(.subheadline.bold())
                    Image(systemName: "chevron.down").font(.caption2.bold())
                }.padding(.leading, 4).padding(.trailing, 10).padding(.vertical, 4)
                    .background(.white.opacity(0.88), in: Capsule())
            }.accessibilityLabel("Selected pet: \(current.name). Switch pets")
        }
    }
}

struct PetMenuSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    let pets: [PetProfile]
    @Binding var selectedPetID: String
    let openMemories: () -> Void
    let editPlayStuff: () -> Void
    let scanBreed: () -> Void
    let addPet: () -> Void
    @State private var photoItem: PhotosPickerItem?
    private var selectedPet: PetProfile? { pets.first { $0.id.uuidString == selectedPetID } ?? pets.first }

    var body: some View {
        ZStack {
            PetCareBackdrop()
            ScrollView {
                VStack(spacing: 18) {
                    Text("Your pet crew").font(.system(size: 30, weight: .bold, design: .rounded))
                    Text("Pick a pet or update what Pawprint knows.").foregroundStyle(Color.sniffMuted)
                    HStack(spacing: 12) {
                        ForEach(pets) { pet in
                            Button {
                                selectedPetID = pet.id.uuidString
                            } label: {
                                VStack(spacing: 8) {
                                    PetAvatar(pet: pet, size: 64, animated: false)
                                    Text(pet.name).font(.headline).lineLimit(1)
                                    if pet.id.uuidString == selectedPetID {
                                        Label("Active", systemImage: "checkmark.circle.fill").font(.caption.bold()).foregroundStyle(Color.sniffAqua)
                                    }
                                }.frame(maxWidth: .infinity).padding(13)
                                    .background(.white.opacity(0.94), in: RoundedRectangle(cornerRadius: 24))
                                    .overlay { RoundedRectangle(cornerRadius: 24).stroke(pet.id.uuidString == selectedPetID ? Color.sniffAqua : Color.sniffLine, lineWidth: 2) }
                            }.buttonStyle(.plain)
                        }
                    }
                    if let pet = selectedPet {
                        PhotosPicker(selection: $photoItem, matching: .images) {
                            themedAction("Change \(pet.name)’s photo", icon: "camera.fill", color: .sniffBerry)
                        }
                        .onChange(of: photoItem) { _, item in loadPhoto(item, for: pet) }
                    }
                    Button(action: openMemories) { themedAction("\(selectedPet?.name ?? "Pet")’s memories", icon: "photo.stack.fill", color: .sniffBerry) }.buttonStyle(.plain)
                    Button(action: editPlayStuff) { themedAction("Update play stuff", icon: "shippingbox.fill", color: .sniffAqua) }.buttonStyle(.plain)
                    Button(action: scanBreed) { themedAction("Scan breed & energy", icon: "viewfinder", color: .sniffPurple) }.buttonStyle(.plain)
                    Button(action: addPet) { themedAction("Add another pet", icon: "plus.circle.fill", color: .sniffMango) }.buttonStyle(.plain)
                }.padding(22)
            }
        }
    }

    private func themedAction(_ title: String, icon: String, color: Color) -> some View {
        HStack(spacing: 14) {
            Image(systemName: icon).font(.title3.bold()).foregroundStyle(.white).frame(width: 42, height: 42).background(color, in: Circle())
            Text(title).font(.headline).foregroundStyle(Color.sniffInk)
            Spacer(); Image(systemName: "chevron.right").font(.caption.bold()).foregroundStyle(color)
        }.padding(14).background(.white.opacity(0.94), in: RoundedRectangle(cornerRadius: 22))
            .overlay { RoundedRectangle(cornerRadius: 22).stroke(color.opacity(0.18)) }
    }

    private func loadPhoto(_ item: PhotosPickerItem?, for pet: PetProfile) {
        guard let item else { return }
        Task {
            if let data = try? await item.loadTransferable(type: Data.self) {
                await MainActor.run {
                    pet.avatarData = data
                    try? modelContext.save()
                    photoItem = nil
                }
            }
        }
    }
}

struct MaterialEditorView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    let pet: PetProfile
    @State private var selected: Set<Material>
    @State private var searchText = ""

    init(pet: PetProfile) {
        self.pet = pet
        _selected = State(initialValue: pet.materials)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                PetCareBackdrop()
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        VStack(spacing: 8) {
                            PetAvatar(pet: pet, size: 78)
                            Text("Build \(pet.name)’s play cupboard")
                                .font(.system(size: 31, weight: .bold, design: .rounded)).multilineTextAlignment(.center)
                            Text("Tap everything you can grab without a shopping trip.")
                                .foregroundStyle(.secondary).multilineTextAlignment(.center)
                        }.frame(maxWidth: .infinity)
                        HStack(spacing: 10) {
                            Image(systemName: "magnifyingglass").foregroundStyle(Color.sniffPurple)
                            TextField("Search towels, toys, boxes…", text: $searchText)
                        }.padding(14).background(.white, in: RoundedRectangle(cornerRadius: 18))
                            .shadow(color: Color.sniffPurple.opacity(0.09), radius: 12, y: 5)
                        ForEach(MaterialGroup.allCases) { group in
                            let values = filteredMaterials(in: group)
                            if !values.isEmpty {
                                VStack(alignment: .leading, spacing: 12) {
                                    HStack {
                                        Circle().fill(groupColor(group)).frame(width: 11, height: 11)
                                        Text(group.rawValue).font(.title3.bold())
                                        Spacer()
                                        Text("\(values.filter(selected.contains).count) picked").font(.caption.bold()).foregroundStyle(groupColor(group))
                                    }
                                    LazyVGrid(columns: [.init(.flexible()), .init(.flexible()), .init(.flexible())], spacing: 11) {
                                        ForEach(values) { material in
                                            MaterialTile(material: material, selected: selected.contains(material), color: groupColor(group)) {
                                                withAnimation(.spring(response: 0.3, dampingFraction: 0.58)) {
                                                    if selected.contains(material) { selected.remove(material) } else { selected.insert(material) }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }.padding().padding(.bottom, 90)
                }
            }
                .navigationTitle("Play stuff").navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                }
                .safeAreaInset(edge: .bottom) {
                    Button { save() } label: { Text("Save \(selected.count) things").frame(maxWidth: .infinity) }
                        .buttonStyle(PrimaryButtonStyle()).padding(.horizontal).padding(.vertical, 10).background(.ultraThinMaterial)
                }
        }
    }

    private func filteredMaterials(in group: MaterialGroup) -> [Material] {
        Material.allCases.filter { material in
            material.group == group && material.fits(pet.species) &&
            (searchText.isEmpty || material.label.localizedCaseInsensitiveContains(searchText))
        }
    }
    private func groupColor(_ group: MaterialGroup) -> Color {
        switch group { case .household: .sniffAqua; case .toys: .sniffPurple; case .snacks: .sniffMango; case .knickKnacks: .sniffBerry }
    }

    private func save() {
        pet.materialRaws = selected.map(\.rawValue).sorted()
        try? modelContext.save()
        dismiss()
    }
}

struct PetProfileEditorView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    let pet: PetProfile
    @State private var energyRaw: String
    @State private var temperament: String
    @State private var sensitivities: String
    @State private var health: String
    @State private var situation: String

    init(pet: PetProfile) {
        self.pet = pet
        _energyRaw = State(initialValue: pet.energyRaw)
        _temperament = State(initialValue: pet.temperamentNote)
        _sensitivities = State(initialValue: pet.sensitivityNote)
        _health = State(initialValue: pet.healthContextNote)
        _situation = State(initialValue: pet.currentSituationNote)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Current energy") {
                    Picker("Energy", selection: $energyRaw) { ForEach(EnergyLevel.allCases) { Text($0.rawValue.capitalized).tag($0.rawValue) } }
                        .pickerStyle(.segmented)
                }
                Section("What Pawprint should know") {
                    TextField("Temperament", text: $temperament, axis: .vertical)
                    TextField("Sensitivities", text: $sensitivities, axis: .vertical)
                    TextField("Health context", text: $health, axis: .vertical)
                    TextField("What’s happening lately", text: $situation, axis: .vertical)
                }
                Section { Text("Keep this brief. Pawprint learns mainly from finished play, elapsed time, reactions, and skips.").font(.caption).foregroundStyle(.secondary) }
            }
            .navigationTitle("Update \(pet.name)").navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) { Button("Save") { save() }.bold() }
            }
        }
    }
    private func save() {
        pet.energyRaw = energyRaw; pet.temperamentNote = temperament; pet.sensitivityNote = sensitivities
        pet.healthContextNote = health; pet.currentSituationNote = situation; pet.profileUpdatedAt = .now
        try? modelContext.save(); dismiss()
    }
}

struct MaterialTile: View {
    let material: Material; let selected: Bool; let color: Color; let action: () -> Void
    var body: some View {
        Button(action: action) {
            VStack(spacing: 9) {
                ZStack(alignment: .topTrailing) {
                    Image(systemName: material.icon).font(.system(size: 25, weight: .semibold))
                        .foregroundStyle(selected ? .white : color)
                        .frame(width: 52, height: 52).background(selected ? color : color.opacity(0.12), in: RoundedRectangle(cornerRadius: 17))
                        .symbolEffect(.bounce, value: selected)
                    if selected { Image(systemName: "checkmark.circle.fill").font(.caption).foregroundStyle(.white).background(color, in: Circle()).offset(x: 5, y: -5) }
                }
                Text(material.label).font(.system(size: 11, weight: .bold, design: .rounded)).multilineTextAlignment(.center).lineLimit(2)
            }.frame(maxWidth: .infinity, minHeight: 100).padding(7)
                .background(.white.opacity(selected ? 1 : 0.72), in: RoundedRectangle(cornerRadius: 20))
                .overlay { RoundedRectangle(cornerRadius: 20).stroke(selected ? color : .clear, lineWidth: 2) }
                .scaleEffect(selected ? 1.04 : 0.96)
        }.buttonStyle(.plain).sensoryFeedback(.selection, trigger: selected)
    }
}

enum PawprintSection: String, CaseIterable, Identifiable {
    case play, fetch, care
    var id: Self { self }
    var label: String { rawValue.capitalized }
    var icon: String { switch self { case .play: "pawprint.fill"; case .fetch: "bubble.left.fill"; case .care: "checklist" } }
    var color: Color { switch self { case .play: .sniffAqua; case .fetch: .sniffPurple; case .care: .sniffMango } }
}

struct PawprintTabBar: View {
    @Binding var selection: PawprintSection
    @Namespace private var selectionAnimation
    var body: some View {
        HStack(spacing: 4) {
            ForEach(PawprintSection.allCases) { item in
                Button {
                    withAnimation(.spring(response: 0.34, dampingFraction: 0.68)) { selection = item }
                } label: {
                    VStack(spacing: 4) {
                        ZStack {
                            if selection == item {
                                Capsule().fill(item == .play ? Color.sniffButter : item.color).frame(width: 48, height: 30)
                                    .matchedGeometryEffect(id: "tabSelection", in: selectionAnimation)
                            }
                            PetTabIcon(section: item, selected: selection == item)
                        }.frame(height: 31)
                        Text(item.label).font(.system(size: 10, weight: selection == item ? .bold : .semibold, design: .rounded))
                            .foregroundStyle(selection == item ? item.color : Color.sniffInk.opacity(0.55))
                    }.frame(maxWidth: .infinity)
                }.buttonStyle(.plain).accessibilityAddTraits(selection == item ? .isSelected : [])
            }
        }
        .padding(.horizontal, 10).padding(.top, 10).padding(.bottom, 7)
        .background(.white.opacity(0.94))
        .clipShape(UnevenRoundedRectangle(topLeadingRadius: 24, topTrailingRadius: 24))
        .shadow(color: Color.sniffPurple.opacity(0.12), radius: 18, y: -4)
        .sensoryFeedback(.selection, trigger: selection)
    }
}

struct PetTabIcon: View {
    let section: PawprintSection
    let selected: Bool
    var body: some View {
        ZStack(alignment: .topTrailing) {
            Image(systemName: section.icon)
                .font(.system(size: 18, weight: .bold))
            if section == .fetch {
                Image(systemName: "pawprint.fill")
                    .font(.system(size: 7, weight: .bold))
                    .padding(2).background(selected ? section.color : .white, in: Circle())
                    .foregroundStyle(selected ? .white : section.color)
                    .offset(x: 6, y: -5)
            }
        }
        .foregroundStyle(selected ? (section == .play ? Color.sniffAqua : .white) : Color.sniffInk.opacity(0.5))
        .symbolEffect(.bounce, value: selected)
        .scaleEffect(selected ? 1.12 : 1)
        .accessibilityHidden(true)
    }
}

struct TodayView: View {
    let pet: PetProfile
    let availablePets: [PetProfile]
    let openCare: () -> Void
    @Query(sort: \EnrichmentSession.completedAt, order: .reverse) private var sessions: [EnrichmentSession]
    @Query private var favoriteRecords: [FavoriteActivity]
    @Query(sort: \EngagementEntry.recordedAt, order: .reverse) private var engagementEntries: [EngagementEntry]
    @Query(sort: \CareTask.createdAt, order: .reverse) private var careTasks: [CareTask]
    @State private var showingPlaySheet = false
    @State private var editingProfile = false
    @State private var showingProgress = false
    @State private var showingBadges = false
    private let library = try? ActivityLibrary()
    private var activity: Activity? {
        return library?.recommendation(for: pet, history: ActivityLibrary.history(for: pet, sessions: sessions), favorites: Set(petFavorites.map(\.activityID)))
    }
    private var moreIdeas: [Activity] {
        let safe = library?.filteredActivities(for: pet, availableMaterialsOnly: false) ?? []
        guard let activity else { return safe }
        return [activity] + safe.filter { $0.id != activity.id }
    }
    private var petSessions: [EnrichmentSession] { sessions.filter { $0.petID == pet.id || ($0.petID == nil && $0.petName == pet.name) } }
    private var petFavorites: [FavoriteActivity] { favoriteRecords.filter { $0.petID == pet.id } }
    private var petEngagement: [EngagementEntry] { engagementEntries.filter { $0.petID == pet.id } }
    private var totalMinutes: Int {
        petSessions.reduce(0) { $0 + $1.actualMinutes }
    }
    var body: some View {
        ZStack(alignment: .top) {
            PetCareBackdrop()
            ScrollView {
                VStack(spacing: 16) {
                    petBlock
                    if shouldSuggestProfileCheckIn { profileCheckIn }
                    playBlock
                    quickWidgets
                }
                .padding()
            }
        }
        .scrollIndicators(.visible).scrollBounceBehavior(.always)
        .background(Color.sniffPaper).navigationBarTitleDisplayMode(.inline)
        .fullScreenCover(isPresented: $showingPlaySheet) {
            PlayTimeSheet(pet: pet, availablePets: availablePets, activities: moreIdeas)
        }
        .sheet(isPresented: $editingProfile) { PetProfileEditorView(pet: pet) }
        .sheet(isPresented: $showingProgress) { progressDetail }
        .sheet(isPresented: $showingBadges) { badgeLibrary }
    }
    private var petBlock: some View {
        VStack(spacing: 12) {
            PetAvatar(pet: pet, size: 92)
            VStack(spacing: 3) {
                Text(pet.name).font(.system(size: 30, weight: .bold, design: .rounded))
                Text("\(petSessions.count) plays together").font(.caption.bold()).foregroundStyle(Color.sniffMuted)
            }
            Button { showingProgress = true } label: {
                HStack(spacing: 9) {
                    Image(systemName: "clock.fill").foregroundStyle(Color.sniffMango)
                    Text("\(recentMinutes) min this week").font(.subheadline.bold())
                    Spacer()
                    playMixBar.frame(width: 112, height: 8)
                    Image(systemName: "chevron.right").font(.caption2.bold()).foregroundStyle(Color.sniffPurple)
                }
                .foregroundStyle(Color.sniffInk).padding(.horizontal, 12).padding(.vertical, 9)
                .background(Color.sniffLavender.opacity(0.5), in: Capsule())
            }.buttonStyle(.plain).accessibilityHint("Shows weekly progress and badges")
        }.padding(18).background(.white.opacity(0.94), in: RoundedRectangle(cornerRadius: 28))
            .overlay { RoundedRectangle(cornerRadius: 28).stroke(Color.sniffPurple.opacity(0.12)) }
    }
    private var shouldSuggestProfileCheckIn: Bool {
        let staleDate = Calendar.current.date(byAdding: .day, value: -30, to: .now) ?? .now
        let recentSignals = petSessions.prefix(3)
        let changedBehavior = recentSignals.filter { $0.reaction == .notInterested || $0.reaction == .tooHard || $0.earlyStopReason == .uncomfortable }.count >= 2
        return pet.profileUpdatedAt < staleDate || changedBehavior
    }
    private var profileCheckIn: some View {
        Button { editingProfile = true } label: {
            HStack(spacing: 12) {
                Image(systemName: "slider.horizontal.3").foregroundStyle(Color.sniffPurple)
                VStack(alignment: .leading, spacing: 2) {
                    Text("Has anything changed?").font(.subheadline.bold())
                    Text("A quick profile check can improve today’s ideas.").font(.caption).foregroundStyle(Color.sniffMuted)
                }
                Spacer(); Image(systemName: "chevron.right").font(.caption.bold()).foregroundStyle(Color.sniffMuted)
            }.padding(14).background(Color.sniffLavender.opacity(0.65), in: RoundedRectangle(cornerRadius: 20))
        }.buttonStyle(.plain)
    }
    private var playBlock: some View {
        Button { showingPlaySheet = true } label: {
            VStack(spacing: 10) {
                Image(systemName: "pawprint.fill").font(.title.bold()).foregroundStyle(Color.sniffPurple)
                    .frame(width: 56, height: 56).background(Color.sniffButter, in: RoundedRectangle(cornerRadius: 19))
                Text("Play with \(pet.name)").font(.system(.title2, design: .rounded, weight: .heavy))
                HStack(spacing: 6) {
                    Text("Start a moment together")
                    Image(systemName: "arrow.right.circle.fill")
                }.font(.subheadline.bold()).foregroundStyle(.white.opacity(0.86))
            }.frame(maxWidth: .infinity).foregroundStyle(.white).padding(20).contentShape(Rectangle())
        }.buttonStyle(.plain)
            .background(LinearGradient(colors: [.sniffPurple, .sniffBerry], startPoint: .leading, endPoint: .trailing), in: RoundedRectangle(cornerRadius: 28))
            .shadow(color: Color.sniffPurple.opacity(0.28), radius: 16, y: 8)
    }
    private var quickWidgets: some View {
        HStack(alignment: .top, spacing: 12) {
            Button(action: openCare) {
                VStack(alignment: .center, spacing: 10) {
                    Image(systemName: "checklist").font(.title3.bold()).foregroundStyle(Color.sniffGold)
                        .frame(width: 38, height: 38).background(Color.sniffButter.opacity(0.75), in: Circle())
                    Text("Care").font(.headline).frame(maxWidth: .infinity)
                    Text(careWidgetText).font(.caption).foregroundStyle(Color.sniffMuted).multilineTextAlignment(.center).lineLimit(2, reservesSpace: true)
                    Spacer(minLength: 0)
                    Text(dueCareTasks.isEmpty ? "All set" : "View reminder").font(.caption2.bold()).foregroundStyle(Color.sniffGold)
                }
                .frame(maxWidth: .infinity, minHeight: 132, alignment: .top).padding(15).contentShape(Rectangle())
            }.buttonStyle(.plain).frame(maxWidth: .infinity).background(.white.opacity(0.94), in: RoundedRectangle(cornerRadius: 22))
                .overlay { RoundedRectangle(cornerRadius: 22).stroke(Color.sniffGold.opacity(0.16)) }

            Button { showingBadges = true } label: {
                VStack(alignment: .center, spacing: 10) {
                    ZStack {
                        Circle().fill(LinearGradient(colors: [.sniffMango, .sniffPink], startPoint: .topLeading, endPoint: .bottomTrailing))
                        Image(systemName: badgeWidgetTrack.symbol).font(.title3.bold()).foregroundStyle(.white)
                    }.frame(width: 46, height: 46).shadow(color: Color.sniffPink.opacity(0.22), radius: 7, y: 4)
                    Text("Badges").font(.headline).frame(maxWidth: .infinity)
                    Text(badgeWidgetTrack.earnedLevel ?? badgeWidgetTrack.nextLevel ?? "Keep playing together")
                        .font(.caption).foregroundStyle(Color.sniffMuted).multilineTextAlignment(.center).lineLimit(2, reservesSpace: true)
                    Spacer(minLength: 0)
                    Text("Open collection").font(.caption2.bold()).foregroundStyle(Color.sniffBerry)
                }
                .frame(maxWidth: .infinity, minHeight: 132, alignment: .top).padding(15).contentShape(Rectangle())
            }.buttonStyle(.plain).frame(maxWidth: .infinity).background(LinearGradient(colors: [.white, Color.sniffPeach.opacity(0.42)], startPoint: .top, endPoint: .bottom), in: RoundedRectangle(cornerRadius: 22))
                .overlay { RoundedRectangle(cornerRadius: 22).stroke(Color.sniffPurple.opacity(0.14)) }
        }
    }
    private var progressDetail: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    VStack(alignment: .leading, spacing: 14) {
                        Text("\(recentMinutes) minutes with \(pet.name) this week").font(.system(.title2, design: .rounded, weight: .bold))
                        Label(careBadge, systemImage: "heart.circle.fill").font(.caption.bold()).foregroundStyle(Color.sniffAqua)
                        HStack(alignment: .bottom, spacing: 9) {
                            ForEach(Array(weeklyMinutes.enumerated()), id: \.offset) { index, minutes in
                                VStack(spacing: 6) {
                                    RoundedRectangle(cornerRadius: 7).fill(LinearGradient(colors: [.sniffPurple, .sniffBerry], startPoint: .bottom, endPoint: .top))
                                        .frame(height: max(10, CGFloat(minutes) / CGFloat(max(weeklyMinutes.max() ?? 1, 1)) * 74))
                                    Text(dayLabels[index]).font(.caption2.bold()).foregroundStyle(Color.sniffMuted)
                                }.frame(maxWidth: .infinity, alignment: .bottom)
                            }
                        }.frame(height: 102, alignment: .bottom)
                        HStack(spacing: 12) {
                            metricTile(value: "\(recentMinutes)", label: "min this week", icon: "clock.fill", color: .sniffMango)
                            metricTile(value: engagementLabel, label: "engagement", icon: "heart.fill", color: .sniffBerry)
                        }
                    }.padding(18).background(.white.opacity(0.95), in: RoundedRectangle(cornerRadius: 28))
                    playMixDetail
                    playInsights
                    Button { showingProgress = false; editingProfile = true } label: {
                        Label("Update \(pet.name)’s profile", systemImage: "slider.horizontal.3")
                    }.buttonStyle(.bordered).tint(.sniffPurple)
                }.padding()
            }
            .background(Color.sniffPaper)
            .navigationTitle("Progress")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement: .confirmationAction) { Button("Done") { showingProgress = false } } }
        }
    }
    private var badgeLibrary: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("\(pet.name)’s badge book").font(.system(.largeTitle, design: .rounded, weight: .bold))
                        Text("Little celebrations for showing up together.").foregroundStyle(Color.sniffMuted)
                    }
                    LazyVGrid(columns: [.init(.flexible()), .init(.flexible())], spacing: 13) {
                        ForEach(Array(badgeTracks.enumerated()), id: \.element.id) { index, track in
                            badgeTile(track, index: index)
                        }
                    }
                }.padding()
            }
            .background(LinearGradient(colors: [Color.sniffPaper, Color.sniffLavender.opacity(0.45), Color.sniffPeach.opacity(0.35)], startPoint: .top, endPoint: .bottom))
            .toolbar { ToolbarItem(placement: .confirmationAction) { Button("Done") { showingBadges = false } } }
        }
    }
    private func badgeTile(_ track: AchievementTrack, index: Int) -> some View {
        let colors: [(Color, Color)] = [(.sniffMango, .sniffPink), (.sniffAqua, .sniffSky), (.sniffPurple, .sniffBerry), (.sniffCoral, .sniffMango), (.sniffPink, .sniffPurple), (.sniffMint, .sniffAqua)]
        let pair = colors[index % colors.count]
        let earned = track.earnedLevel != nil
        return VStack(spacing: 10) {
            ZStack {
                Circle().fill(LinearGradient(colors: earned ? [pair.0, pair.1] : [Color.sniffLine, Color.sniffLine.opacity(0.55)], startPoint: .topLeading, endPoint: .bottomTrailing))
                Circle().stroke(.white.opacity(0.7), lineWidth: 3).padding(6)
                Image(systemName: track.symbol).font(.system(size: 28, weight: .bold)).foregroundStyle(.white)
            }.frame(width: 78, height: 78).shadow(color: earned ? pair.0.opacity(0.25) : .clear, radius: 9, y: 5)
            Text(track.earnedLevel ?? track.nextLevel ?? track.title).font(.subheadline.bold()).multilineTextAlignment(.center).lineLimit(2, reservesSpace: true)
            if earned {
                Label("Earned", systemImage: "sparkles").font(.caption2.bold()).foregroundStyle(pair.1)
            } else {
                ProgressView(value: track.progress).tint(pair.0)
                Text(badgeProgress(track)).font(.caption2).foregroundStyle(Color.sniffMuted)
            }
        }.frame(maxWidth: .infinity, minHeight: 170).padding(14)
            .background(.white.opacity(0.88), in: RoundedRectangle(cornerRadius: 26))
            .overlay { RoundedRectangle(cornerRadius: 26).stroke(pair.0.opacity(earned ? 0.28 : 0.1)) }
    }
    private func badgeProgress(_ track: AchievementTrack) -> String {
        switch track.id {
        case "weekly-time", "lifetime-time": "\(track.current)/\(track.target) min"
        case "good-days": "\(track.current)/\(track.target) days"
        case "explorer": "\(track.current)/\(track.target) styles"
        default: "\(track.current)/\(track.target)"
        }
    }
    private var playMixBar: some View {
        GeometryReader { geometry in
            let values = playCategoryMinutes.filter { $0.value > 0 }
            let total = max(values.reduce(0) { $0 + $1.value }, 1)
            if values.isEmpty {
                Capsule().fill(Color.sniffLine)
            } else {
                HStack(spacing: 2) {
                    ForEach(ActivityCategory.allCases.filter { playCategoryMinutes[$0, default: 0] > 0 }) { category in
                        Capsule().fill(category.accent)
                            .frame(width: max(5, (geometry.size.width - CGFloat(values.count - 1) * 2) * CGFloat(playCategoryMinutes[category, default: 0]) / CGFloat(total)))
                    }
                }
            }
        }.clipShape(Capsule()).accessibilityLabel("Weekly play mix by activity type")
    }
    private var playMixDetail: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Play mix").font(.system(.title2, design: .rounded, weight: .bold))
            Text("How your time together breaks down this week.").font(.caption).foregroundStyle(Color.sniffMuted)
            playMixBar.frame(height: 14)
            if playCategoryMinutes.values.allSatisfy({ $0 == 0 }) {
                Label("Complete a play moment to start seeing \(pet.name)’s mix.", systemImage: "paintpalette.fill")
                    .font(.subheadline).foregroundStyle(Color.sniffMuted).padding(.vertical, 6)
            } else {
                LazyVGrid(columns: [.init(.flexible()), .init(.flexible())], alignment: .leading, spacing: 10) {
                    ForEach(ActivityCategory.allCases.filter { playCategoryMinutes[$0, default: 0] > 0 }) { category in
                        HStack(spacing: 7) {
                            Circle().fill(category.accent).frame(width: 10, height: 10)
                            Text(category.funLabel).font(.caption.bold())
                            Spacer()
                            Text("\(playCategoryMinutes[category, default: 0])m").font(.caption).foregroundStyle(Color.sniffMuted)
                        }
                    }
                }
            }
        }.padding(18).background(.white.opacity(0.95), in: RoundedRectangle(cornerRadius: 28))
            .overlay { RoundedRectangle(cornerRadius: 28).stroke(Color.sniffAqua.opacity(0.14)) }
    }
    private var playInsights: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("What we’re learning", systemImage: "lightbulb.fill").font(.system(.title3, design: .rounded, weight: .bold)).foregroundStyle(Color.sniffMango)
            if petSessions.count < 3 {
                Text("A few more play moments will help us spot what keeps \(pet.name) engaged and what they’d rather skip.")
                    .font(.subheadline).foregroundStyle(Color.sniffMuted)
                HStack(spacing: 7) {
                    ForEach(0..<3, id: \.self) { index in
                        Circle().fill(index < petSessions.count ? Color.sniffMango : Color.sniffLine).frame(width: 9, height: 9)
                    }
                    Text("\(petSessions.count) of 3 moments logged").font(.caption.bold()).foregroundStyle(Color.sniffMuted)
                }
            } else {
                Label(playSuccessTip, systemImage: "heart.fill").font(.subheadline).foregroundStyle(Color.sniffInk)
                Label(playAdjustmentTip, systemImage: "arrow.triangle.2.circlepath").font(.subheadline).foregroundStyle(Color.sniffInk)
            }
        }.padding(18).background(LinearGradient(colors: [Color.sniffButter.opacity(0.72), Color.sniffPeach.opacity(0.45)], startPoint: .topLeading, endPoint: .bottomTrailing), in: RoundedRectangle(cornerRadius: 28))
    }
    private func metricTile(value: String, label: String, icon: String, color: Color) -> some View {
        HStack(spacing: 9) {
            Image(systemName: icon).foregroundStyle(color)
            VStack(alignment: .leading, spacing: 1) { Text(value).font(.headline); Text(label).font(.caption2.bold()).foregroundStyle(Color.sniffMuted) }
        }.frame(maxWidth: .infinity, alignment: .leading).padding(11).background(color.opacity(0.09), in: RoundedRectangle(cornerRadius: 16))
    }
    private var calendar: Calendar { Calendar.current }
    private var weeklyMinutes: [Int] {
        (0..<7).reversed().map { offset in
            let day = calendar.date(byAdding: .day, value: -offset, to: .now) ?? .now
            return petSessions.filter { calendar.isDate($0.completedAt, inSameDayAs: day) }.reduce(0) { total, session in
                total + session.actualMinutes
            }
        }
    }
    private var recentWeekSessions: [EnrichmentSession] {
        let cutoff = calendar.date(byAdding: .day, value: -7, to: .now) ?? .now
        return petSessions.filter { $0.completedAt >= cutoff }
    }
    private var playCategoryMinutes: [ActivityCategory: Int] {
        Dictionary(grouping: recentWeekSessions, by: \.category).mapValues { $0.reduce(0) { $0 + $1.actualMinutes } }
    }
    private var playSuccessTip: String {
        let loved = petSessions.filter { $0.reaction == .loved }
        guard let favorite = Dictionary(grouping: loved, by: \.category).max(by: { $0.value.count < $1.value.count })?.key else {
            return "Keep varying the play style while we learn what clicks."
        }
        return "\(favorite.funLabel) is getting \(pet.name)’s happiest reactions."
    }
    private var playAdjustmentTip: String {
        let misses = petSessions.filter { $0.reaction == .notInterested || $0.reaction == .tooHard }
        guard let category = Dictionary(grouping: misses, by: \.category).max(by: { $0.value.count < $1.value.count })?.key else {
            return "No strong dislikes yet—short, varied sessions are working well."
        }
        return "Try shorter or gentler \(category.funLabel.lowercased()) sessions next time."
    }
    private var dayLabels: [String] { (0..<7).reversed().map { offset in let date = calendar.date(byAdding: .day, value: -offset, to: .now) ?? .now; return String(calendar.shortWeekdaySymbols[calendar.component(.weekday, from: date) - 1].prefix(1)) } }
    private var recentMinutes: Int { weeklyMinutes.reduce(0, +) }
    private var dueCareTasks: [CareTask] { careTasks.filter { $0.petID == pet.id && $0.isDue } }
    private var careWidgetText: String {
        guard let task = dueCareTasks.first else { return "No reminders right now" }
        return dueCareTasks.count == 1 ? task.title : "\(task.title) + \(dueCareTasks.count - 1) more"
    }
    private var badgeTracks: [AchievementTrack] { AchievementEngine.tracks(history: ActivityLibrary.history(for: pet, sessions: sessions)) }
    private var badgeWidgetTrack: AchievementTrack { badgeTracks.first { $0.nextLevel != nil } ?? badgeTracks[0] }
    private var careBadge: String { petSessions.count >= 10 ? "Enrichment champion" : petSessions.count >= 3 ? "Thoughtful play partner" : petSessions.isEmpty ? "Ready for your first play" : "Great start" }
    private var engagementLabel: String {
        let recent = petEngagement.prefix(7)
        guard !recent.isEmpty else { return "Learning" }
        let average = Double(recent.reduce(0) { $0 + $1.levelRaw }) / Double(recent.count)
        return average >= 4 ? "High" : average >= 2.5 ? "Steady" : "Gentle"
    }
}

struct PlayTimeSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \EnrichmentSession.completedAt, order: .reverse) private var sessions: [EnrichmentSession]
    @Query private var favorites: [FavoriteActivity]
    let pet: PetProfile
    let availablePets: [PetProfile]
    let activities: [Activity]
    @State private var availableMinutes = 5
    @State private var intent: PlayIntent?
    @State private var dayPeriod = DayPeriod.current()
    @State private var selectedPetIDs: Set<UUID>
    private let library = try? ActivityLibrary()
    init(pet: PetProfile, availablePets: [PetProfile], activities: [Activity]) {
        self.pet = pet; self.availablePets = availablePets; self.activities = activities
        _selectedPetIDs = State(initialValue: [pet.id])
        _intent = State(initialValue: pet.recentPlayIntent)
    }
    private var selectedPets: [PetProfile] { availablePets.filter { selectedPetIDs.contains($0.id) } }
    private var compatibleCompanions: [PetProfile] { availablePets.filter { $0.id != pet.id && $0.species == pet.species } }
    private var suggestions: [Activity] {
        guard let intent, let library else { return [] }
        var contextualCategories = intent.categories + dayPeriod.categories
        if pet.isNearMeal() { contextualCategories.insert(.calming, at: 0) }
        if pet.foodMotivation == .high { contextualCategories.append(.foraging) }
        if pet.socialStyle == .interactive { contextualCategories.append(.social) }
        if pet.noiseSensitive { contextualCategories.append(.calming) }
        let categories = contextualCategories.reduce(into: [ActivityCategory]()) { result, category in
            if !result.contains(category) { result.append(category) }
        }
        let petHistory = ActivityLibrary.history(for: pet, sessions: sessions)
        let petFavorites = Set(favorites.filter { $0.petID == pet.id }.map(\.activityID))
        return Array(library.rankedRecommendations(for: pet, history: petHistory, favorites: petFavorites, preferredCategories: categories, maximumMinutes: availableMinutes)
            .filter { activity in selectedPets.allSatisfy { player in activityFits(activity, pet: player) } }.prefix(3))
    }
    var body: some View {
        NavigationStack {
            ZStack {
                Color.sniffPaper.ignoresSafeArea()
                ScrollView {
                VStack(spacing: 22) {
                    HStack { Text("Play time").font(.system(.title, design: .rounded, weight: .bold)); Spacer(); Button { dismiss() } label: { Image(systemName: "xmark").frame(width: 38, height: 38).background(.white, in: Circle()) }.buttonStyle(.plain) }
                    HStack(spacing: -12) {
                        ForEach(selectedPets) { player in PetAvatar(pet: player, size: 72, animated: false) }
                    }
                    if !compatibleCompanions.isEmpty {
                        HStack(spacing: 10) {
                            Text("Playing together").font(.caption.bold()).foregroundStyle(Color.sniffMuted)
                            ForEach(compatibleCompanions) { companion in
                                Button {
                                    if selectedPetIDs.contains(companion.id) { selectedPetIDs.remove(companion.id) } else { selectedPetIDs.insert(companion.id) }
                                } label: {
                                    PetAvatar(pet: companion, size: 42, animated: false).opacity(selectedPetIDs.contains(companion.id) ? 1 : 0.48)
                                        .overlay(Circle().stroke(selectedPetIDs.contains(companion.id) ? Color.sniffAqua : .clear, lineWidth: 3))
                                }.buttonStyle(.plain).accessibilityLabel("Include \(companion.name)")
                            }
                        }
                    }
                    VStack(alignment: .leading, spacing: 10) {
                        HStack { Text("Time available").font(.headline); Spacer(); Text("\(availableMinutes) min").font(.headline).foregroundStyle(Color.sniffAqua) }
                        Slider(value: Binding(get: { Double(availableMinutes) }, set: { availableMinutes = Int($0.rounded()) }), in: 3...30, step: 1).tint(.sniffAqua)
                    }.padding(15).background(.white, in: RoundedRectangle(cornerRadius: 20))
                    HStack {
                        Label("Time of day", systemImage: dayPeriod.symbol).font(.headline)
                        Spacer()
                        Picker("Time of day", selection: $dayPeriod) { ForEach(DayPeriod.allCases) { Text($0.label).tag($0) } }.pickerStyle(.menu).tint(.sniffPurple)
                    }.padding(15).background(.white, in: RoundedRectangle(cornerRadius: 20))
                    VStack(alignment: .leading, spacing: 10) {
                        Text("How is \(pet.name) right now?").font(.headline)
                        LazyVGrid(columns: [.init(.flexible()), .init(.flexible())], spacing: 9) {
                            ForEach(PlayIntent.allCases) { item in
                                Button { remember(item) } label: {
                                    Label(item.title(for: pet.species), systemImage: item.symbol).frame(maxWidth: .infinity, minHeight: 42)
                                }.buttonStyle(.bordered).tint(intent == item ? .sniffAqua : .gray)
                            }
                        }
                    }
                    if intent == nil {
                        Text("Choose one to see the best fits.").font(.subheadline.bold()).foregroundStyle(Color.sniffMuted).frame(maxWidth: .infinity)
                    } else {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Best fits").font(.title3.bold())
                            ForEach(suggestions) { suggestion in
                                NavigationLink { ActivityDetailView(activity: suggestion, pet: pet) } label: {
                                    HStack(spacing: 12) {
                                        Image(suggestion.artworkName).resizable().scaledToFill().frame(width: 68, height: 68).clipped().clipShape(RoundedRectangle(cornerRadius: 16))
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(suggestion.title).font(.headline).foregroundStyle(Color.sniffInk).lineLimit(2)
                                            Text("\(suggestion.durationMinutes) min · \(suggestion.category.funLabel)").font(.caption.bold()).foregroundStyle(Color.sniffMuted)
                                        }
                                        Spacer(); Image(systemName: "play.circle.fill").font(.title2).foregroundStyle(Color.sniffAqua)
                                    }
                                    .padding(10).background(.white, in: RoundedRectangle(cornerRadius: 20))
                                }.buttonStyle(.plain)
                            }
                        }
                    }
                    NavigationLink { LibraryView(pet: pet) } label: { Label("Browse play library", systemImage: "square.grid.2x2.fill").frame(maxWidth: .infinity) }.buttonStyle(.bordered).tint(.sniffAqua)
                    Spacer()
                }.padding(22)
                }
            }.toolbar(.hidden, for: .navigationBar)
        }
    }
    private func remember(_ newIntent: PlayIntent) {
        intent = newIntent
        pet.lastPlayIntentRaw = newIntent.rawValue
        pet.lastPlayContextAt = .now
        try? modelContext.save()
    }
    private func activityFits(_ activity: Activity, pet: PetProfile) -> Bool {
        activity.species == pet.species && activity.ageBands.contains(pet.ageBand) && activity.sizeBands.contains(pet.sizeBand) &&
        activity.energyLevels.contains(pet.energy) && activity.exclusions.allSatisfy { !pet.limitations.contains($0) }
    }
}

struct VibePicker: View {
    let species: Species
    @Binding var selection: Set<PetContext>
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            contextRow(title: "What are you noticing?", values: PetContext.allCases.filter { !$0.isEnvironment })
            contextRow(title: "What’s going on around them?", values: PetContext.allCases.filter(\.isEnvironment))
        }
    }
    private func contextRow(title: String, values: [PetContext]) -> some View {
        VStack(alignment: .leading, spacing: 9) {
            Text(title).font(.headline)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 9) {
                    ForEach(values) { item in
                        let picked = selection.contains(item)
                        Button {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.65)) {
                                if picked {
                                    selection.remove(item)
                                } else {
                                    selection = Set(selection.filter { $0.isEnvironment != item.isEnvironment })
                                    selection.insert(item)
                                }
                            }
                        } label: {
                            VStack(spacing: 6) {
                                Image(systemName: item.icon).font(.title3).symbolEffect(.bounce, value: picked)
                                Text(item.label(for: species)).font(.caption.bold()).lineLimit(2).multilineTextAlignment(.center)
                            }.frame(width: 100, height: 72)
                                .background(picked ? contextColor(item) : .white.opacity(0.82), in: RoundedRectangle(cornerRadius: 19))
                                .foregroundStyle(picked ? .white : Color.sniffInk)
                                .overlay { RoundedRectangle(cornerRadius: 19).stroke(contextColor(item).opacity(picked ? 0 : 0.22)) }
                                .scaleEffect(picked ? 1 : 0.95)
                        }.buttonStyle(.plain).accessibilityAddTraits(picked ? .isSelected : [])
                    }
                }.padding(.vertical, 3)
            }
        }
    }
    private func contextColor(_ item: PetContext) -> Color {
        switch item.categories.first ?? .sensory { case .calming: .sniffSky; case .cognitive: .sniffBerry; case .physical: .sniffAqua; case .foraging: .sniffMango; case .social: .sniffCoral; case .sensory: .sniffPurple }
    }
}

struct ActivityCard: View {
    let activity: Activity
    var body: some View {
        VStack(alignment: .leading, spacing: 13) {
            Image(artName).resizable().scaledToFill().frame(maxWidth: .infinity).frame(height: 178).clipped()
                .clipShape(RoundedRectangle(cornerRadius: 18))
                .overlay(alignment: .bottom) {
                    LinearGradient(colors: [.clear, activity.category.accent.opacity(0.42)], startPoint: .center, endPoint: .bottom)
                        .clipShape(RoundedRectangle(cornerRadius: 18))
                }
                .overlay(alignment: .bottomTrailing) {
                    Image(systemName: icon).font(.title2.bold()).foregroundStyle(.white).padding(12)
                        .background(activity.category.accent, in: Circle()).padding(10)
                }
            HStack { Text(activity.category.funLabel).badge(color: activity.category.accent); Text("\(activity.durationMinutes) min").badge(color: activity.category.accent) }
            Text(activity.title).font(.system(.title, design: .rounded, weight: .bold))
            Label("Tap to start", systemImage: "play.fill").font(.subheadline.bold()).foregroundStyle(activity.category.accent)
        }.padding().background(activity.category.softColor, in: RoundedRectangle(cornerRadius: 26)).overlay { RoundedRectangle(cornerRadius: 26).stroke(activity.category.accent.opacity(0.32), lineWidth: 1.5) }.shadow(color: activity.category.accent.opacity(0.18), radius: 18, y: 9)
    }
    private var artName: String { activity.artworkName }
    private var icon: String { switch activity.category { case .foraging: "nose"; case .sensory: "wind"; case .cognitive: "puzzlepiece.fill"; case .physical: "figure.run"; case .social: "heart.fill"; case .calming: "moon.stars.fill" } }
}

struct ActivityFlipCard: View {
    let activity: Activity; let pet: PetProfile
    var body: some View {
        NavigationLink { ActivityDetailView(activity: activity, pet: pet) } label: {
            ActivityCard(activity: activity)
        }
        .buttonStyle(.plain)
        .accessibilityHint("Opens the guided activity")
    }
}

extension ActivityCategory {
    var accent: Color {
        switch self { case .foraging: .sniffMango; case .sensory: .sniffPurple; case .cognitive: .sniffBerry; case .physical: .sniffAqua; case .social: .sniffCoral; case .calming: .sniffSky }
    }
    var softColor: Color { accent.opacity(0.13) }
    var funLabel: String {
        switch self { case .foraging: "Sniff & Seek"; case .sensory: "Explore"; case .cognitive: "Brain Game"; case .physical: "Move"; case .social: "Together"; case .calming: "Chill" }
    }
}

struct FetchView: View {
    let pet: PetProfile
    @State private var prompt = ""
    @State private var answer: String?
    @FocusState private var focused: Bool
    private let library = try? ActivityLibrary()
    private let suggestions = ["Something quick", "Use what I have", "Help them settle", "Make it harder"]

    var body: some View {
        ZStack {
            PetCareBackdrop()
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(alignment: .leading, spacing: 22) {
                        PetPageHeader(pet: pet, eyebrow: "PET-SMART IDEAS", title: "Ask Fetch", subtitle: "A playful helper that already knows \(pet.name)’s setup.", color: .sniffPurple, icon: "bubble.left.fill")

                        if answer == nil {
                            VStack(spacing: 11) {
                                Image(systemName: "pawprint.fill").font(.system(size: 38, weight: .bold)).foregroundStyle(Color.sniffPurple)
                                Text("What would help right now?").font(.system(.title2, design: .rounded, weight: .bold))
                                Text("Ask for an easier version, a quick idea, or something using what’s nearby.").foregroundStyle(Color.sniffMuted).multilineTextAlignment(.center)
                            }.frame(maxWidth: .infinity).padding(24).background(.white.opacity(0.9), in: RoundedRectangle(cornerRadius: 28)).shadow(color: Color.sniffPurple.opacity(0.1), radius: 16, y: 7)
                        } else if let answer {
                            HStack(alignment: .top, spacing: 12) {
                                FetchSpark(size: 38)
                                Text(answer).font(.system(.body, design: .rounded, weight: .medium)).lineSpacing(5).frame(maxWidth: .infinity, alignment: .leading)
                            }
                            .padding(20).background(.white.opacity(0.94), in: RoundedRectangle(cornerRadius: 26))
                            .overlay { RoundedRectangle(cornerRadius: 26).stroke(Color.sniffPurple.opacity(0.16)) }
                            .shadow(color: Color.sniffPurple.opacity(0.1), radius: 14, y: 6).id("answer")
                        }

                        Menu {
                            ForEach(suggestions, id: \.self) { suggestion in
                                Button(suggestion) { prompt = suggestion; ask() }
                            }
                        } label: {
                            Label("Try a quick prompt", systemImage: "sparkles")
                                .font(.subheadline.bold()).padding(.horizontal, 16).padding(.vertical, 11)
                                .background(Color.sniffLavender, in: Capsule()).foregroundStyle(Color.sniffPurple)
                        }
                        .frame(maxWidth: .infinity, alignment: .center)

                        VStack(alignment: .leading, spacing: 10) {
                            HStack(alignment: .bottom, spacing: 10) {
                                TextField("Ask about \(pet.name)…", text: $prompt, axis: .vertical)
                                    .focused($focused).lineLimit(1...5).submitLabel(.send).onSubmit(ask)
                                Button(action: ask) {
                                    Image(systemName: "pawprint.fill").font(.headline).frame(width: 38, height: 38)
                                        .background(prompt.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? Color.sniffLavender : Color.sniffPurple, in: Circle())
                                        .foregroundStyle(prompt.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? Color.sniffMuted : .white)
                                }.buttonStyle(.plain).disabled(prompt.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                            }
                            .padding(.leading, 8).padding(.trailing, 7).padding(.vertical, 8)
                            .background(.white, in: RoundedRectangle(cornerRadius: 24))
                            .overlay { RoundedRectangle(cornerRadius: 24).stroke(focused ? Color.sniffPurple : Color.sniffLine, lineWidth: focused ? 2 : 1) }
                            .shadow(color: Color.sniffPurple.opacity(focused ? 0.14 : 0.08), radius: 16, y: 7)
                            Text("Suggestions come from Pawprint’s reviewed play library.").font(.caption2).foregroundStyle(Color.sniffMuted).padding(.leading, 8)
                        }
                    }.padding()
                }.scrollIndicators(.visible).scrollBounceBehavior(.always).scrollDismissesKeyboard(.interactively)
                    .onChange(of: answer) { _, _ in withAnimation { proxy.scrollTo("answer", anchor: .center) } }
            }
        }.navigationBarTitleDisplayMode(.inline)
    }

    private func ask() {
        let question = prompt.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !question.isEmpty else { return }
        let safe = library?.safeActivities(for: pet) ?? []
        let lower = question.lowercased()
        let match: Activity? = {
            if lower.contains("settle") || lower.contains("calm") { return safe.first { $0.category == .calming } }
            if lower.contains("quick") { return safe.min { $0.durationMinutes < $1.durationMinutes } }
            if lower.contains("hard") { return safe.max { $0.tier < $1.tier } }
            return safe.first
        }()
        if let match {
            answer = "Try \(match.title). It takes about \(match.durationMinutes) minutes and uses \(match.materials.map(\.label).joined(separator: ", ")). \(match.description) Want the full steps? Tap Play and you’ll find it with the other ideas."
        } else {
            answer = "I couldn’t find a match using \(pet.name)’s current materials. Add another material to their setup, or ask me for a simpler version."
        }
        prompt = ""; focused = false
    }
}

struct FetchSpark: View {
    let size: CGFloat
    var body: some View {
        Circle().fill(LinearGradient(colors: [.sniffPurple, .sniffBlue], startPoint: .topLeading, endPoint: .bottomTrailing))
            .frame(width: size, height: size)
            .overlay(Image(systemName: "pawprint.fill").font(.system(size: size * 0.42, weight: .bold)).foregroundStyle(.white))
            .shadow(color: Color.sniffBlue.opacity(0.22), radius: 10, y: 5).accessibilityHidden(true)
    }
}

struct CareView: View {
    let pet: PetProfile
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \HouseholdMember.createdAt) private var allMembers: [HouseholdMember]
    @Query(sort: \CareTask.createdAt, order: .reverse) private var allTasks: [CareTask]
    @Query(sort: \CareCompletion.completedAt, order: .reverse) private var allCompletions: [CareCompletion]
    @State private var addingCare = false
    private var members: [HouseholdMember] { allMembers.filter { $0.petID == pet.id } }
    private var tasks: [CareTask] { allTasks.filter { $0.petID == pet.id }.sorted { $0.isDue && !$1.isDue } }
    private var weeklyCompletions: [CareCompletion] {
        let cutoff = Calendar.current.date(byAdding: .day, value: -7, to: .now) ?? .now
        return allCompletions.filter { $0.petID == pet.id && $0.completedAt >= cutoff }
    }

    var body: some View {
        ZStack {
            PetCareBackdrop()
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    PetPageHeader(pet: pet, eyebrow: "THE CARE PLAN", title: "\(pet.name)’s day", subtitle: "The little jobs that keep one very important pet happy.", color: .sniffGold, icon: "checklist")

                    VStack(alignment: .leading, spacing: 8) {
                        Label("This week", systemImage: "checkmark.seal.fill").font(.headline).foregroundStyle(Color.sniffMint)
                        Text(weeklyCompletions.isEmpty ? "Ready when you are." : "\(weeklyCompletions.count) care \(weeklyCompletions.count == 1 ? "item" : "items") completed.")
                            .foregroundStyle(Color.sniffMuted)
                    }.padding(18).frame(maxWidth: .infinity, alignment: .leading).background(Color.sniffButter.opacity(0.75), in: RoundedRectangle(cornerRadius: 24))

                    VStack(alignment: .leading, spacing: 14) {
                        HStack {
                            Label("Care checklist", systemImage: "checklist").font(.system(.title2, design: .rounded, weight: .bold)).foregroundStyle(Color.sniffGold)
                            Spacer()
                            Text("\(tasks.filter(\.isDue).count) to do").font(.caption.bold()).foregroundStyle(Color.sniffMuted)
                        }
                        if tasks.isEmpty {
                            ContentUnavailableView("No care items", systemImage: "checkmark.circle", description: Text("Add only the routines that help \(pet.name)."))
                        }
                        ForEach(tasks) { task in
                            Button { complete(task) } label: {
                                HStack(spacing: 12) {
                                    Image(systemName: task.isDue ? "circle" : "checkmark.circle.fill").font(.title2).foregroundStyle(task.isDue ? Color.sniffGold.opacity(0.55) : Color.sniffMint)
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(task.title).strikethrough(!task.isDue).font(.headline)
                                        Text("\(task.kind.label) · \(task.cadence.label)").font(.caption).foregroundStyle(Color.sniffMuted)
                                        Text(dueText(for: task)).font(.caption2.bold()).foregroundStyle(task.isDue ? Color.sniffGold : Color.sniffMuted)
                                        if let id = task.assignedMemberID, let person = members.first(where: { $0.id == id }) { Text(person.name).font(.caption).foregroundStyle(Color.sniffMuted) }
                                    }; Spacer()
                                }.padding(.vertical, 3)
                            }.buttonStyle(.plain)
                            Divider().opacity(0.55)
                        }
                    }.padding(20).background(.white.opacity(0.94), in: RoundedRectangle(cornerRadius: 28)).overlay { RoundedRectangle(cornerRadius: 28).stroke(Color.sniffGold.opacity(0.2)) }.shadow(color: Color.sniffGold.opacity(0.11), radius: 15, y: 7)
                    Button { addingCare = true } label: { Label("Add care item", systemImage: "plus.circle.fill") }.buttonStyle(PrimaryButtonStyle())
                    if !weeklyCompletions.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Label("Recent care", systemImage: "clock.arrow.circlepath").font(.headline).foregroundStyle(Color.sniffGold)
                            ForEach(Array(weeklyCompletions.prefix(5))) { completion in
                                HStack {
                                    Label(completion.kind.label, systemImage: completion.kind.symbol)
                                    Spacer()
                                    Text(completion.completedAt, format: .dateTime.weekday(.abbreviated).hour().minute())
                                        .font(.caption).foregroundStyle(Color.sniffMuted)
                                }
                            }
                        }.padding(18).background(.white.opacity(0.92), in: RoundedRectangle(cornerRadius: 24))
                    }
                    Label("For pain, severe matting, or sudden sensitivity, contact a veterinarian or professional groomer.", systemImage: "heart.text.square.fill")
                        .font(.caption).foregroundStyle(Color.sniffMuted).padding(.horizontal, 4)
                }.padding()
            }.scrollBounceBehavior(.always)
        }.navigationTitle("Care").navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $addingCare) { AddCareSheet(pet: pet, members: members) }
    }
    private func complete(_ task: CareTask) {
        if task.isDue {
            modelContext.insert(CareCompletion(task: task)); task.lastCompletedAt = .now
        }
        task.isDone = true; try? modelContext.save()
    }
    private func dueText(for task: CareTask) -> String {
        if task.isDue { return "Due now" }
        guard let date = task.nextDueDate else { return "As needed" }
        return "Next \(date.formatted(.relative(presentation: .named)))"
    }
}

struct AddCareSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    let pet: PetProfile
    let members: [HouseholdMember]
    @State private var title = ""
    @State private var kind: CareKind = .brushing
    @State private var cadence: CareCadence = .weekly
    @State private var assignee: UUID?
    @State private var consentGuidance = true

    var body: some View {
        NavigationStack {
            Form {
                Section("Care item") {
                    TextField("What needs doing?", text: $title)
                    Picker("Type", selection: $kind) { ForEach(CareKind.allCases) { Label($0.label, systemImage: $0.symbol).tag($0) } }
                    Picker("Repeat", selection: $cadence) { ForEach(CareCadence.allCases) { Text($0.label).tag($0) } }
                    if !members.isEmpty {
                        Picker("Assigned to", selection: $assignee) {
                            Text("Anyone").tag(UUID?.none)
                            ForEach(members) { Text($0.name).tag(Optional($0.id)) }
                        }
                    }
                    Toggle("Show consent guidance", isOn: $consentGuidance)
                }
                if consentGuidance {
                    Section("Comfort first") {
                        Label("Invite contact, pause when \(pet.name) pulls away, and split care into shorter sessions when needed.", systemImage: "hand.raised.fill")
                        Text("Care guidance supports cooperative handling. It never replaces veterinary advice.").font(.caption).foregroundStyle(.secondary)
                    }
                }
                Section { Text("Completion adds to the weekly care summary, not play minutes or a streak.").font(.caption).foregroundStyle(.secondary) }
            }
            .navigationTitle("Add care").navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) { Button("Add") { save() }.disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty) }
            }
        }
    }
    private func save() {
        modelContext.insert(CareTask(petID: pet.id, title: title.trimmingCharacters(in: .whitespacesAndNewlines), assignedMemberID: assignee, kind: kind, cadence: cadence, consentGuidanceEnabled: consentGuidance))
        try? modelContext.save(); dismiss()
    }
}

struct BreedScanPlaceholder: View {
    @Environment(\.dismiss) private var dismiss
    let pet: PetProfile
    var body: some View {
        ZStack {
            PetCareBackdrop()
            VStack(spacing: 22) {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("PAWPRINT VISION").font(.caption.bold()).tracking(1.4).foregroundStyle(Color.sniffPurple)
                        Text("A smarter pet snapshot").font(.title3.bold())
                    }
                    Spacer()
                    Button { dismiss() } label: {
                        Image(systemName: "xmark").font(.headline).frame(width: 40, height: 40)
                            .background(.white, in: Circle()).foregroundStyle(Color.sniffInk)
                    }.buttonStyle(.plain).accessibilityLabel("Close")
                }
                Spacer()
                ZStack {
                    RoundedRectangle(cornerRadius: 36).fill(LinearGradient(colors: [Color.sniffLavender, Color.sniffPeach, Color.sniffButter], startPoint: .topLeading, endPoint: .bottomTrailing)).frame(height: 280)
                    RoundedRectangle(cornerRadius: 28).strokeBorder(style: StrokeStyle(lineWidth: 3, dash: [12, 9])).foregroundStyle(Color.sniffPurple.opacity(0.42)).padding(22)
                    VStack(spacing: 14) {
                        Image(systemName: pet.species == .cat ? "cat.fill" : "dog.fill").font(.system(size: 82, weight: .semibold)).foregroundStyle(Color.sniffPurple)
                            .phaseAnimator([false, true]) { content, up in content.offset(y: up ? -5 : 3) } animation: { _ in .easeInOut(duration: 0.8) }
                        Label("Center \(pet.name) here", systemImage: "viewfinder").font(.headline).foregroundStyle(Color.sniffBerry)
                    }
                }
                Text("Breed & energy scan").font(.system(.largeTitle, design: .rounded, weight: .bold))
                Text("This will use a photo to suggest possible breed traits, energy patterns, and care questions—not diagnose \(pet.name) or claim certainty.").foregroundStyle(.secondary).multilineTextAlignment(.center)
                Label("AI camera preview · coming later", systemImage: "sparkles").font(.subheadline.bold()).foregroundStyle(Color.sniffPurple).padding().background(.white.opacity(0.9), in: RoundedRectangle(cornerRadius: 18))
                Spacer()
            }.padding(24)
        }.presentationBackground(Color.sniffPaper)
    }
}

struct LibraryView: View {
    let pet: PetProfile
    @State private var maximumMinutes = 15
    @State private var category: ActivityCategory?
    @State private var material: Material?
    @State private var materialsOnly = false
    private let library = try? ActivityLibrary()
    private var activities: [Activity] {
        (library?.filteredActivities(for: pet, maximumMinutes: maximumMinutes, category: category, availableMaterialsOnly: materialsOnly) ?? [])
            .filter { material == nil || $0.materials.contains(material!) }
    }
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                Text("Play & enrichment").font(.system(.largeTitle, design: .rounded, weight: .bold))
                Text("Safe play, discovery, and bonding ideas for \(pet.name).").foregroundStyle(.secondary)
                VStack(alignment: .leading, spacing: 14) {
                    Text("FILTERS").font(.caption.bold()).tracking(1.2).foregroundStyle(Color.sniffBlue)
                    HStack { Text("Up to \(maximumMinutes) minutes"); Slider(value: Binding(get: { Double(maximumMinutes) }, set: { maximumMinutes = Int($0) }), in: 3...30, step: 1).accessibilityLabel("Maximum activity duration") }
                    Toggle("Only materials we have", isOn: $materialsOnly)
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            FilterChip(title: "All", selected: category == nil) { category = nil }
                            ForEach(ActivityCategory.allCases) { item in FilterChip(title: item.rawValue.capitalized, selected: category == item) { category = item } }
                        }
                    }
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            FilterChip(title: "Any material", selected: material == nil) { material = nil }
                            ForEach(pet.materials.sorted { $0.label < $1.label }) { item in FilterChip(title: item.label, selected: material == item) { material = item } }
                        }
                    }.accessibilityLabel("Material filter")
                }.padding().background(Color.sniffSurface, in: RoundedRectangle(cornerRadius: 18)).overlay { RoundedRectangle(cornerRadius: 18).stroke(Color.sniffLine) }
                Text("\(activities.count) \(activities.count == 1 ? "idea" : "ideas") for \(pet.name)").font(.subheadline.bold())
                if activities.isEmpty { ContentUnavailableView("No matches", systemImage: "line.3.horizontal.decrease.circle", description: Text("Try more time, another category, or include activities needing other materials.")) }
                ForEach(activities) { activity in
                    NavigationLink { ActivityDetailView(activity: activity, pet: pet) } label: { ActivityCard(activity: activity) }.buttonStyle(.plain)
                }
            }.padding()
        }.background(Color.sniffPaper).navigationTitle("Play library").navigationBarTitleDisplayMode(.inline)
    }
}

struct FilterChip: View {
    let title: String; let selected: Bool; let action: () -> Void
    var body: some View { Button(title, action: action).buttonStyle(.bordered).buttonBorderShape(.capsule).tint(selected ? .sniffBlue : .gray).accessibilityAddTraits(selected ? .isSelected : []) }
}

private enum GuidedPhase: Hashable { case materials, step(Int), ready, playing, finished }

struct ActivityDetailView: View {
    let activity: Activity; let pet: PetProfile
    var combinedSessionID: UUID? = nil
    var combinedActivityIDs: [String] = []
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \EnrichmentSession.completedAt, order: .reverse) private var allSessions: [EnrichmentSession]
    @State private var phase: GuidedPhase = .materials
    @State private var setupSeconds = 0
    @State private var playSeconds = 0
    @State private var isPaused = false
    @State private var completing = false
    @State private var completionSaved = false
    @State private var mediaMessage: String?
    private let ticker = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        ZStack {
            PetCareBackdrop()
            VStack(spacing: 0) {
                progressHeader
                ZStack { phaseContent.id(phase).transition(.asymmetric(insertion: .move(edge: .trailing).combined(with: .opacity), removal: .move(edge: .leading).combined(with: .opacity))) }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .navigationBarBackButtonHidden(phase == .playing)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) { if phase != .playing { Button { dismiss() } label: { Image(systemName: "xmark") } } }
            ToolbarItem(placement: .topBarTrailing) {
                if phase != .playing && phase != .finished {
                    Button("Skip setup") { withAnimation { phase = .playing } }.font(.subheadline.bold()).foregroundStyle(flowColor)
                }
            }
        }
        .onReceive(ticker) { _ in
            if case .playing = phase {
                if !isPaused {
                    playSeconds += 1
                    if playSeconds >= activity.durationMinutes * 60 { withAnimation { phase = .finished } }
                }
            }
            else if phase != .finished { setupSeconds += 1 }
        }
        .sheet(isPresented: $completing, onDismiss: { if completionSaved { dismiss() } }) {
            CompletionView(activity: activity, pet: pet, actualDurationSeconds: playSeconds, combinedSessionID: combinedSessionID, combinedActivityIDs: combinedActivityIDs) { completionSaved = true }
        }
        .alert("Camera preview", isPresented: Binding(get: { mediaMessage != nil }, set: { if !$0 { mediaMessage = nil } })) { Button("Got it") { mediaMessage = nil } } message: { Text(mediaMessage ?? "") }
    }

    private var progressHeader: some View {
        HStack(spacing: 7) {
            ForEach(0..<progressCount, id: \.self) { index in
                Capsule().fill(index <= progressIndex ? flowColor : Color.sniffLine)
                    .frame(height: 6).animation(.spring(response: 0.35), value: progressIndex)
            }
        }.padding(.horizontal, 24).padding(.top, 12)
    }
    private var progressCount: Int { activity.steps.count + 3 }
    private var progressIndex: Int {
        switch phase { case .materials: 0; case .step(let index): index + 1; case .ready: activity.steps.count + 1; case .playing, .finished: activity.steps.count + 2 }
    }

    @ViewBuilder private var phaseContent: some View {
        switch phase {
        case .materials: materialScreen
        case .step(let index): stepScreen(index)
        case .ready: readyScreen
        case .playing: timerScreen
        case .finished: finishedScreen
        }
    }
    private var materialScreen: some View {
        GuidedMoment(icon: "shippingbox.fill", color: flowColor, eyebrow: hasPlayedBefore ? "WELCOME BACK" : "FIRST, GRAB THIS", title: activity.materials.isEmpty ? "Just you and \(pet.name)" : activity.materials.map(\.label).joined(separator: " + "), detail: hasPlayedBefore ? "You’ve done this one before, so you can jump right in." : "Bring everything nearby so play can stay uninterrupted.") {
            if hasPlayedBefore {
                VStack(spacing: 10) {
                    Button("Start again") { withAnimation { phase = .playing } }.buttonStyle(PrimaryButtonStyle())
                    Button("Review setup") { advanceToStep(0) }.font(.subheadline.bold()).foregroundStyle(flowColor)
                }
            } else {
                Button("Got it!") { advanceToStep(0) }.buttonStyle(PrimaryButtonStyle())
            }
        }
    }
    private func stepScreen(_ index: Int) -> some View {
        GuidedMoment(icon: stepIcon(index), color: flowColor, eyebrow: "SETUP · \(index + 1) OF \(activity.steps.count)", title: activity.steps[index], detail: index == 0 ? "No rush. \(pet.name) can watch while you get ready." : "Perfect. Keep it simple and let curiosity do the work.") {
            Button(index == activity.steps.count - 1 ? "We’re ready" : "Got it—next") {
                if index + 1 < activity.steps.count { withAnimation { phase = .step(index + 1) } } else { withAnimation { phase = .ready } }
            }.buttonStyle(PrimaryButtonStyle())
        }
    }
    private var readyScreen: some View {
        GuidedMoment(icon: "heart.fill", color: .sniffPink, eyebrow: "SETUP TOOK \(formatted(setupSeconds))", title: "Ready when \(pet.name) is", detail: "The play timer starts only when you tap below. Stop anytime they lose interest.") {
            Button { withAnimation { phase = .playing } } label: { Label("Start playtime", systemImage: "play.fill") }.buttonStyle(PrimaryButtonStyle())
        }
    }
    private var timerScreen: some View {
        VStack(spacing: 22) {
            Spacer()
            PetAvatar(pet: pet, size: 82)
            Text(activity.title).font(.title2.bold()).multilineTextAlignment(.center)
            ZStack {
                Circle().stroke(flowColor.opacity(0.13), lineWidth: 18)
                Circle().trim(from: 0, to: min(CGFloat(playSeconds) / CGFloat(max(activity.durationMinutes * 60, 1)), 1))
                    .stroke(flowColor, style: StrokeStyle(lineWidth: 18, lineCap: .round)).rotationEffect(.degrees(-90))
                    .animation(.linear(duration: 1), value: playSeconds)
                VStack(spacing: 3) { Text(formatted(playSeconds)).font(.system(size: 52, weight: .bold, design: .rounded)).monospacedDigit(); Text("playing together").font(.caption.bold()).foregroundStyle(.secondary) }
            }.frame(width: 230, height: 230)
            Menu {
                Button { mediaMessage = "Photo capture will open here in the production build." } label: { Label("Take photo", systemImage: "camera.fill") }
                Button { mediaMessage = "Video capture will open here in the production build." } label: { Label("Take video", systemImage: "video.fill") }
            } label: {
                Label("Add a memory", systemImage: "camera.fill")
                    .font(.subheadline.bold()).padding(.horizontal, 16).padding(.vertical, 11)
                    .background(.white, in: Capsule())
            }
            .buttonStyle(.plain).shadow(color: Color.sniffPurple.opacity(0.1), radius: 8, y: 4)
            Text(playSeconds < activity.durationMinutes * 60 ? "Follow \(pet.name)’s lead—finishing early still counts." : "Lovely work. Keep going if they’re still engaged.")
                .font(.subheadline.weight(.semibold)).foregroundStyle(.secondary).multilineTextAlignment(.center).padding(.horizontal)
            HStack(spacing: 12) {
                Button { isPaused.toggle() } label: { Label(isPaused ? "Resume" : "Pause", systemImage: isPaused ? "play.fill" : "pause.fill") }.buttonStyle(.bordered).buttonBorderShape(.capsule)
                Button("Finish") { withAnimation { phase = .finished } }.buttonStyle(.borderedProminent).buttonBorderShape(.capsule).tint(flowColor)
            }
            Spacer()
        }.padding()
    }
    private var finishedScreen: some View {
        GuidedMoment(icon: "checkmark", color: flowColor, eyebrow: "ACTIVITY COMPLETE · \(formatted(playSeconds))", title: "You showed up for \(pet.name)", detail: "That play time supported their enrichment and your bond.") {
            Button("Finish and save") { completing = true }.buttonStyle(PrimaryButtonStyle())
        }
    }
    private var flowColor: Color { .sniffAqua }
    private var hasPlayedBefore: Bool { allSessions.contains { $0.activityID == activity.id && ($0.petID == pet.id || ($0.petID == nil && $0.petName == pet.name)) } }
    private func advanceToStep(_ index: Int) { withAnimation { phase = activity.steps.isEmpty ? .ready : .step(index) } }
    private func stepIcon(_ index: Int) -> String { ["hand.raised.fill", "sparkles", "pawprint.fill", "heart.fill"][index % 4] }
    private func formatted(_ seconds: Int) -> String { String(format: "%d:%02d", seconds / 60, seconds % 60) }
}

struct GuidedMoment<Actions: View>: View {
    let icon: String; let color: Color; let eyebrow: String; let title: String; let detail: String; let actions: Actions
    init(icon: String, color: Color, eyebrow: String, title: String, detail: String, @ViewBuilder actions: () -> Actions) { self.icon = icon; self.color = color; self.eyebrow = eyebrow; self.title = title; self.detail = detail; self.actions = actions() }
    var body: some View {
        VStack(spacing: 22) {
            Spacer()
            Image(systemName: icon).font(.system(size: 48, weight: .bold)).foregroundStyle(.white)
                .frame(width: 106, height: 106).background(color, in: RoundedRectangle(cornerRadius: 34))
                .rotationEffect(.degrees(-3)).shadow(color: color.opacity(0.25), radius: 20, y: 10)
                .phaseAnimator([false, true]) { content, floating in content.offset(y: floating ? -4 : 3).rotationEffect(.degrees(floating ? 2 : -3)) } animation: { _ in .easeInOut(duration: 1.35) }
            Text(eyebrow).font(.caption.bold()).tracking(1.3).foregroundStyle(color)
            Text(title).font(.system(size: 34, weight: .bold, design: .rounded)).multilineTextAlignment(.center).lineLimit(4).minimumScaleFactor(0.72)
            Text(detail).font(.title3).foregroundStyle(.secondary).multilineTextAlignment(.center).lineSpacing(4)
            Spacer()
            actions
        }.padding(28)
    }
}

struct CompletionView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    let activity: Activity; let pet: PetProfile
    let actualDurationSeconds: Int
    var combinedSessionID: UUID? = nil
    var combinedActivityIDs: [String] = []
    var onSaved: () -> Void = {}
    @State private var reaction: Reaction?
    @State private var note = ""
    @State private var earlyStopReason: EarlyStopReason?
    @State private var addOn: Activity?
    @State private var saved = false
    private var endedEarly: Bool { actualDurationSeconds + 15 < activity.durationMinutes * 60 }
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    Image(systemName: "heart.circle.fill").font(.system(size: 54)).foregroundStyle(Color.sniffBlue)
                    Text("A good few minutes.").font(.largeTitle.bold())
                    Text("How was it for \(pet.name)?").font(.title3).foregroundStyle(.secondary)
                    HStack {
                        Label("Preset \(activity.durationMinutes) min", systemImage: "flag.fill")
                        Spacer()
                        Label("Played \(formatted(actualDurationSeconds))", systemImage: "timer")
                    }.font(.caption.bold()).foregroundStyle(Color.sniffMuted).padding(12).background(.white, in: RoundedRectangle(cornerRadius: 15))
                    LazyVGrid(columns: [.init(.flexible()), .init(.flexible())]) {
                        ForEach(Reaction.allCases) { item in
                            Button { reaction = item } label: { Label(item.rawValue, systemImage: item.symbol).frame(maxWidth: .infinity, minHeight: 48) }
                                .buttonStyle(.bordered).tint(reaction == item ? .sniffBlue : .gray)
                        }
                    }
                    if endedEarly {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("What made today shorter?").font(.headline)
                            Text("One tap helps us choose better next time.").font(.caption).foregroundStyle(.secondary)
                            ForEach(EarlyStopReason.allCases) { reason in
                                Button { earlyStopReason = reason } label: {
                                    Label(reason.rawValue, systemImage: reason.symbol).frame(maxWidth: .infinity, alignment: .leading)
                                }.buttonStyle(.bordered).tint(earlyStopReason == reason ? .sniffAqua : .gray)
                            }
                        }
                    }
                    TextField("Anything funny happen? (optional)", text: $note, axis: .vertical)
                        .lineLimit(2...5).padding(15)
                        .background(Color.sniffSurface, in: RoundedRectangle(cornerRadius: 18))
                        .overlay { RoundedRectangle(cornerRadius: 18).stroke(Color.sniffLine) }
                    Button("Save memory") { save() }.buttonStyle(PrimaryButtonStyle()).disabled(reaction == nil || (endedEarly && earlyStopReason == nil))
                    if let suggestion = compatibleAddOn {
                        Button { saveAndAdd(suggestion) } label: { Label("Add another activity", systemImage: "plus.circle.fill") }
                            .buttonStyle(.bordered).tint(.sniffAqua)
                            .disabled(reaction == nil || (endedEarly && earlyStopReason == nil))
                        Text("Optional · \(suggestion.durationMinutes) min · \(suggestion.title)").font(.caption).foregroundStyle(.secondary)
                    }
                }.padding()
            }.background(Color.sniffPaper).navigationTitle("Done").navigationBarTitleDisplayMode(.inline)
        }.fullScreenCover(item: $addOn) { next in
            NavigationStack { ActivityDetailView(activity: next, pet: pet, combinedSessionID: combinedSessionID ?? sessionGroupID, combinedActivityIDs: [activity.id, next.id]) }
        }
    }
    private let sessionGroupID = UUID()
    private var compatibleAddOn: Activity? {
        guard let library = try? ActivityLibrary() else { return nil }
        let preferred = activity.category == .physical ? [ActivityCategory.calming, .sensory] : [ActivityCategory.social, .cognitive, .sensory]
        return library.safeActivities(for: pet).filter { $0.id != activity.id && $0.durationMinutes <= 10 && preferred.contains($0.category) }
            .sorted { $0.durationMinutes < $1.durationMinutes }.first
    }
    private func save() {
        guard let reaction else { return }
        persist(reaction: reaction, groupID: combinedSessionID, activityIDs: combinedActivityIDs); onSaved(); dismiss()
    }
    private func saveAndAdd(_ next: Activity) {
        guard let reaction else { return }
        let group = combinedSessionID ?? sessionGroupID
        persist(reaction: reaction, groupID: group, activityIDs: [activity.id, next.id]); addOn = next
    }
    private func persist(reaction: Reaction, groupID: UUID?, activityIDs: [String]) {
        guard !saved else { return }
        modelContext.insert(EnrichmentSession(activity: activity, pet: pet, reaction: reaction, note: note, actualDurationSeconds: actualDurationSeconds, earlyStopReason: earlyStopReason, combinedSessionID: groupID, combinedActivityIDs: activityIDs))
        try? modelContext.save(); saved = true
    }
    private func formatted(_ seconds: Int) -> String { String(format: "%d:%02d", seconds / 60, seconds % 60) }
}

struct MemoryView: View {
    let pet: PetProfile
    @Query(sort: \EnrichmentSession.completedAt, order: .reverse) private var sessions: [EnrichmentSession]
    private let columns = [GridItem(.adaptive(minimum: 150), spacing: 12)]
    private var petSessions: [EnrichmentSession] { sessions.filter { $0.petID == pet.id || ($0.petID == nil && $0.petName == pet.name) } }
    private var preferenceSummary: String? {
        guard !petSessions.isEmpty else { return nil }
        let loved = petSessions.filter { $0.reaction == .loved }
        let counts = Dictionary(grouping: loved, by: \.category).mapValues { $0.count }
        if let category = counts.max(by: { $0.value < $1.value })?.key { return "\(category.rawValue.capitalized) play has been getting the happiest reactions from \(pet.name)." }
        let gentleCount = petSessions.filter { $0.reaction == .tooHard || $0.reaction == .notInterested }.count
        if gentleCount > 0 { return "A few ideas got a ‘nope’ from \(pet.name). Message received—we’ll mix it up." }
        return "We’re still figuring out \(pet.name)’s favorites. The fun part is trying things together."
    }
    var body: some View {
        ZStack {
            PetCareBackdrop()
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    PetPageHeader(pet: pet, eyebrow: "THE SCRAPBOOK", title: "\(pet.name)’s good stuff", subtitle: "Tiny adventures worth keeping close.", color: .sniffPink, icon: "photo.stack.fill")
                    HStack(spacing: 10) {
                        CareStatChip(icon: "pawprint.fill", value: "\(petSessions.count)", label: "play moments", color: .sniffPink)
                        CareStatChip(icon: "photo.fill", value: "\(petSessions.filter { $0.photoData != nil }.count)", label: "photos", color: .sniffPurple)
                    }
                    if let preferenceSummary {
                        VStack(alignment: .leading, spacing: 8) {
                            Label("A little pattern", systemImage: "chart.line.uptrend.xyaxis").font(.headline).foregroundStyle(Color.sniffPurple)
                            Text(preferenceSummary).font(.system(.body, design: .rounded, weight: .medium)).foregroundStyle(Color.sniffInk)
                        }.padding(18).background(.white.opacity(0.92), in: RoundedRectangle(cornerRadius: 24)).shadow(color: Color.sniffPurple.opacity(0.09), radius: 12, y: 6)
                    }
                    if petSessions.isEmpty {
                        VStack(spacing: 12) {
                            Image(systemName: "photo.on.rectangle.angled").font(.system(size: 42)).foregroundStyle(Color.sniffPink)
                            Text("Your scrapbook starts here").font(.title2.bold())
                            Text("Finished activities and photos will collect here—nothing to catch up on.").foregroundStyle(Color.sniffMuted).multilineTextAlignment(.center)
                        }.frame(maxWidth: .infinity).padding(28).background(.white.opacity(0.9), in: RoundedRectangle(cornerRadius: 28))
                    }
                    LazyVGrid(columns: columns, spacing: 12) {
                        ForEach(Array(petSessions.enumerated()), id: \.offset) { index, session in
                            VStack(alignment: .leading, spacing: 8) {
                                if let data = session.photoData, let image = UIImage(data: data) { Image(uiImage: image).resizable().scaledToFill().frame(height: 120).clipped() }
                                else { Rectangle().fill(index.isMultiple(of: 2) ? Color.sniffPeach : Color.sniffLavender).frame(height: 120).overlay(Image(systemName: "pawprint.fill").font(.largeTitle).foregroundStyle(index.isMultiple(of: 2) ? Color.sniffCoral : Color.sniffPurple)) }
                                Text(session.activityTitle).font(.system(.headline, design: .rounded, weight: .bold)).lineLimit(2).padding(.horizontal, 10)
                                Label(session.reaction.rawValue, systemImage: session.reaction.symbol).font(.caption.bold()).foregroundStyle(Color.sniffMuted).padding(.horizontal, 10).padding(.bottom, 10)
                            }.background(.white, in: RoundedRectangle(cornerRadius: 20)).clipShape(RoundedRectangle(cornerRadius: 20)).shadow(color: Color.sniffPink.opacity(0.08), radius: 10, y: 5)
                        }
                    }
                }.padding()
            }.scrollIndicators(.visible).scrollBounceBehavior(.always)
        }.navigationTitle("Memories").navigationBarTitleDisplayMode(.inline)
    }
}

struct ProgressViewScreen: View {
    let pet: PetProfile
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \EngagementEntry.recordedAt, order: .reverse) private var entries: [EngagementEntry]
    @State private var selectedLevel: EngagementLevel = .intoIt
    @State private var note = ""
    @State private var saved = false

    private var petEntries: [EngagementEntry] { entries.filter { $0.petID == pet.id } }
    private var chartEntries: [EngagementEntry] { Array(petEntries.prefix(30).reversed()) }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                Text("What’s \(pet.name)’s vibe?").font(.system(.largeTitle, design: .rounded, weight: .bold))
                Text("Tap the mood. That’s it.").foregroundStyle(.secondary)

                VStack(alignment: .leading, spacing: 16) {
                    Text("RIGHT NOW").font(.caption.bold()).tracking(1.2).foregroundStyle(Color.sniffBlue)
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            ForEach(EngagementLevel.allCases) { level in
                                Button { selectedLevel = level; saved = false } label: {
                                    VStack(spacing: 7) {
                                        Image(systemName: level.symbol).font(.title2)
                                        Text(level.label).font(.caption.bold()).lineLimit(1)
                                    }.frame(width: 92, height: 72)
                                }
                                .buttonStyle(.bordered)
                                .tint(selectedLevel == level ? .sniffBlue : .gray)
                                .accessibilityAddTraits(selectedLevel == level ? .isSelected : [])
                            }
                        }
                    }
                    TextField("What caught their attention? (optional)", text: $note, axis: .vertical).textFieldStyle(.roundedBorder)
                    Button(saved ? "Saved!" : "Save this moment") { save() }.buttonStyle(PrimaryButtonStyle())
                }.padding().background(.white, in: RoundedRectangle(cornerRadius: 20)).overlay { RoundedRectangle(cornerRadius: 20).stroke(Color.sniffLine) }

                if chartEntries.isEmpty {
                    ContentUnavailableView("Their story starts here", systemImage: "chart.line.uptrend.xyaxis", description: Text("Log a play mood and the picture will grow over time."))
                } else {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("\(pet.name)’s vibe check").font(.title2.bold())
                        Text("Just the mood, never a grade.").font(.subheadline).foregroundStyle(.secondary)
                        Chart(chartEntries) { entry in
                            LineMark(x: .value("Date", entry.recordedAt), y: .value("Engagement", entry.levelRaw))
                                .interpolationMethod(.catmullRom).foregroundStyle(Color.sniffBlue)
                            PointMark(x: .value("Date", entry.recordedAt), y: .value("Engagement", entry.levelRaw))
                                .foregroundStyle(Color.sniffBlue).symbolSize(55)
                        }
                        .chartYScale(domain: 1...5)
                        .chartYAxis {
                            AxisMarks(values: [1, 3, 5]) { value in
                                AxisGridLine(); AxisValueLabel {
                                    if let number = value.as(Int.self) { Text(number == 1 ? "Chill" : number == 3 ? "Into it" : "All in") }
                                }
                            }
                        }
                        .frame(height: 230)
                        .accessibilityLabel("Play mood over time for \(pet.name)")
                    }.padding().background(.white, in: RoundedRectangle(cornerRadius: 20)).overlay { RoundedRectangle(cornerRadius: 20).stroke(Color.sniffLine) }

                    VStack(alignment: .leading, spacing: 12) {
                        Text("Recent moments").font(.title2.bold())
                        ForEach(petEntries.prefix(5)) { entry in
                            HStack(spacing: 12) {
                                Image(systemName: entry.level.symbol).foregroundStyle(Color.sniffBlue).frame(width: 28)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(entry.level.label).font(.headline)
                                    if !entry.note.isEmpty { Text(entry.note).font(.subheadline).foregroundStyle(.secondary).lineLimit(2) }
                                }
                                Spacer()
                                Text(entry.recordedAt, format: .dateTime.month(.abbreviated).day()).font(.caption).foregroundStyle(.secondary)
                            }
                            if entry.id != petEntries.prefix(5).last?.id { Divider() }
                        }
                    }
                }
            }.padding()
        }.background(Color.sniffPaper).navigationTitle("Progress").navigationBarTitleDisplayMode(.inline)
    }

    private func save() {
        modelContext.insert(EngagementEntry(petID: pet.id, level: selectedLevel, note: note.trimmingCharacters(in: .whitespacesAndNewlines)))
        try? modelContext.save()
        note = ""
        saved = true
    }
}

struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label.font(.headline).frame(maxWidth: .infinity).padding()
            .background(Color.sniffAqua.opacity(configuration.isPressed ? 0.78 : 1), in: RoundedRectangle(cornerRadius: 16))
            .foregroundStyle(.white).shadow(color: Color.sniffAqua.opacity(configuration.isPressed ? 0.08 : 0.2), radius: 10, y: 5)
            .scaleEffect(configuration.isPressed ? 0.965 : 1)
            .animation(.spring(response: 0.25, dampingFraction: 0.62), value: configuration.isPressed)
            .sensoryFeedback(.impact(weight: .light), trigger: configuration.isPressed)
    }
}
struct FormSection<Content: View>: View {
    let title: String; let content: Content
    init(title: String, @ViewBuilder content: () -> Content) { self.title = title; self.content = content() }
    var body: some View { VStack(alignment: .leading, spacing: 20) { Text(title).font(.largeTitle.bold()); content } }
}
struct EnumPicker<T: RawRepresentable & CaseIterable & Hashable>: View where T.RawValue == String, T.AllCases: RandomAccessCollection {
    let title: String; @Binding var selection: T
    var body: some View {
        LabeledControl(title: title) {
            Picker(title, selection: $selection) { ForEach(Array(T.allCases), id: \.self) { Text($0.rawValue.capitalized).tag($0) } }.pickerStyle(.segmented)
        }
    }
}
struct LabeledControl<Content: View>: View {
    let title: String; let hint: String?; let content: Content
    init(title: String, hint: String? = nil, @ViewBuilder content: () -> Content) { self.title = title; self.hint = hint; self.content = content() }
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title).font(.headline)
            if let hint { Text(hint).font(.caption).foregroundStyle(.secondary) }
            content
        }.frame(maxWidth: .infinity, alignment: .leading)
    }
}
struct MiniPetChoice: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    let species: Species; let action: () -> Void
    private var label: String { species == .dog ? "Dog" : "Cat" }
    private var icon: String { species == .dog ? "dog.fill" : "cat.fill" }
    var body: some View {
        Button(action: action) {
            VStack(spacing: 9) {
                Circle().fill(.white.opacity(0.9)).frame(width: 92, height: 92)
                    .overlay(Circle().stroke(Color.sniffBlue.opacity(0.22), lineWidth: 1.5))
                    .overlay(Image(systemName: icon).font(.system(size: species == .dog ? 31 : 35, weight: .semibold)).foregroundStyle(Color.sniffBlue))
                    .shadow(color: Color.sniffBlue.opacity(0.13), radius: 12, y: 6)
                Text(label).font(.headline).foregroundStyle(Color.sniffInk)
            }
            .phaseAnimator(reduceMotion ? [false] : [false, true]) { content, floating in content.offset(y: floating ? -3 : 3).rotationEffect(.degrees(floating ? 1.2 : -1.2)) } animation: { _ in .easeInOut(duration: 1.6) }
        }.buttonStyle(.plain).accessibilityLabel(label)
    }
}
struct SelectedPetLogo: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    let species: Species
    private var icon: String { species == .dog ? "dog.fill" : "cat.fill" }
    var body: some View {
        Circle().fill(LinearGradient(colors: [Color.sniffBlue, Color.cyan], startPoint: .topLeading, endPoint: .bottomTrailing)).frame(width: 190, height: 190)
            .overlay(Image(systemName: icon).font(.system(size: species == .dog ? 78 : 86, weight: .semibold)).foregroundStyle(.white))
            .overlay(Circle().stroke(.white.opacity(0.7), lineWidth: 5).padding(9))
            .shadow(color: Color.sniffBlue.opacity(0.28), radius: 25, y: 14)
            .phaseAnimator(reduceMotion ? [false] : [false, true]) { content, floating in content.offset(y: floating ? -7 : 5).rotationEffect(.degrees(floating ? 2 : -2)) } animation: { _ in .easeInOut(duration: 1.7) }
            .accessibilityLabel(species == .dog ? "Dog selected" : "Cat selected")
    }
}
struct PlayfulBrandMark: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    let size: CGFloat
    var body: some View {
        Image("BrandMark").resizable().scaledToFit().frame(width: size, height: size).clipShape(RoundedRectangle(cornerRadius: size * 0.23))
            .shadow(color: Color.sniffBlue.opacity(0.2), radius: 14, y: 8)
            .phaseAnimator(reduceMotion ? [false] : [false, true]) { content, floating in content.offset(y: floating ? -5 : 3).rotationEffect(.degrees(floating ? 2 : -2)) } animation: { _ in .easeInOut(duration: 1.8) }
            .accessibilityLabel("Pawprint logo: a white paw and heart on blue")
    }
}
struct PlayfulPetHero: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    let species: Species; var compact = false
    private var icon: String { species == .dog ? "dog.fill" : "cat.fill" }
    var body: some View {
        ZStack {
            HStack(spacing: compact ? 20 : 30) {
                Image(systemName: "pawprint.fill").font(compact ? .title3 : .title2).foregroundStyle(Color.cyan).rotationEffect(.degrees(-18))
                Image(systemName: icon).font(.system(size: compact ? 36 : 48, weight: .semibold)).foregroundStyle(Color.sniffBlue)
                    .phaseAnimator(reduceMotion ? [false] : [false, true]) { content, hop in content.offset(y: hop ? -7 : 3).scaleEffect(hop ? 1.04 : 0.97) } animation: { _ in .spring(duration: 0.8, bounce: 0.45) }
                Image(systemName: "sparkles").font(compact ? .title3 : .title2).foregroundStyle(Color.sniffBlue)
            }
        }.frame(height: compact ? 58 : 76).accessibilityHidden(true)
    }
}
struct PetFace: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    let species: Species
    let size: CGFloat
    var animated = true
    private var imageName: String { "Activity-\(species.rawValue)-social" }
    var body: some View {
        Image(imageName).resizable().scaledToFill()
            .frame(width: size, height: size).clipShape(Circle())
            .overlay(Circle().stroke(.white, lineWidth: max(3, size * 0.055)))
            .overlay(alignment: .bottomTrailing) {
                Image(systemName: "heart.fill").font(.system(size: size * 0.16, weight: .bold))
                    .foregroundStyle(.white).padding(size * 0.08)
                    .background(Color.sniffPink, in: Circle())
                    .overlay(Circle().stroke(.white, lineWidth: 2))
            }
            .shadow(color: Color.sniffPurple.opacity(0.2), radius: size * 0.15, y: size * 0.08)
            .phaseAnimator(animated && !reduceMotion ? [false, true] : [false]) { content, floating in
                content.offset(y: floating ? -4 : 2).rotationEffect(.degrees(floating ? 1.2 : -1.2))
            } animation: { _ in .easeInOut(duration: 1.8) }
            .accessibilityLabel(species == .dog ? "Happy dog" : "Happy cat")
    }
}
struct PetAvatar: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    let pet: PetProfile
    let size: CGFloat
    var animated = true

    var body: some View {
        Group {
            if let data = pet.avatarData, let photo = UIImage(data: data) {
                Image(uiImage: photo).resizable().scaledToFill()
            } else {
                Image("Activity-\(pet.species.rawValue)-social").resizable().scaledToFill()
            }
        }
        .frame(width: size, height: size).clipShape(Circle())
        .overlay(Circle().stroke(.white, lineWidth: max(3, size * 0.055)))
        .overlay(alignment: .bottomTrailing) {
            Image(systemName: pet.avatarData == nil ? "heart.fill" : "camera.fill")
                .font(.system(size: size * 0.14, weight: .bold)).foregroundStyle(.white)
                .padding(size * 0.08).background(Color.sniffBerry, in: Circle())
                .overlay(Circle().stroke(.white, lineWidth: 2))
        }
        .shadow(color: Color.sniffPurple.opacity(0.2), radius: size * 0.15, y: size * 0.08)
        .phaseAnimator(animated && !reduceMotion ? [false, true] : [false]) { content, floating in
            content.offset(y: floating ? -4 : 2).rotationEffect(.degrees(floating ? 1.2 : -1.2))
        } animation: { _ in .easeInOut(duration: 1.8) }
        .accessibilityLabel("Photo of \(pet.name)")
    }
}
struct CareStatChip: View {
    let icon: String
    let value: String
    let label: String
    let color: Color
    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: icon).font(.headline).foregroundStyle(color)
                .frame(width: 36, height: 36).background(color.opacity(0.13), in: Circle())
            VStack(alignment: .leading, spacing: 1) {
                Text(value).font(.title3.bold())
                Text(label).font(.caption2.weight(.semibold)).foregroundStyle(.secondary).lineLimit(1)
            }
        }.frame(maxWidth: .infinity, alignment: .leading).padding(12)
            .background(.white.opacity(0.9), in: RoundedRectangle(cornerRadius: 20))
            .shadow(color: color.opacity(0.09), radius: 10, y: 5)
    }
}
struct PetPageHeader: View {
    let pet: PetProfile
    let eyebrow: String
    let title: String
    let subtitle: String
    let color: Color
    let icon: String
    var body: some View {
        VStack(spacing: 9) {
            ZStack(alignment: .bottomTrailing) {
                PetAvatar(pet: pet, size: 88)
                Image(systemName: icon).font(.caption.bold()).foregroundStyle(.white)
                    .frame(width: 30, height: 30).background(color, in: Circle()).overlay(Circle().stroke(.white, lineWidth: 2))
            }
            Text(eyebrow).font(.system(size: 11, weight: .heavy, design: .rounded)).tracking(1.5).foregroundStyle(color)
            Text(title).font(.system(size: 34, weight: .bold, design: .rounded)).fontWidth(.expanded).multilineTextAlignment(.center)
            Text(subtitle).font(.system(.subheadline, design: .rounded, weight: .medium)).foregroundStyle(Color.sniffMuted).multilineTextAlignment(.center).lineSpacing(3)
        }.frame(maxWidth: .infinity).padding(.vertical, 8)
    }
}
struct PetCareBackdrop: View {
    var body: some View {
        ZStack {
            Color.sniffPaper
            LinearGradient(colors: [Color.sniffLavender.opacity(0.34), Color.sniffPaper, Color.sniffPeach.opacity(0.24)], startPoint: .topLeading, endPoint: .bottomTrailing)
        }.ignoresSafeArea().accessibilityHidden(true)
    }
}
struct AnimatedActivityIcon: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    let name: String
    var body: some View {
        Image(systemName: name).font(.system(size: 48, weight: .semibold)).foregroundStyle(.white)
            .phaseAnimator(reduceMotion ? [false] : [false, true]) { content, active in content.scaleEffect(active ? 1.08 : 0.94).rotationEffect(.degrees(active ? 3 : -3)) } animation: { _ in .easeInOut(duration: 1.3) }
            .accessibilityHidden(true)
    }
}
struct ChoiceGrid<T: Hashable & Identifiable>: View {
    let values: [T]; @Binding var selected: Set<T>; let label: (T) -> String
    var body: some View { LazyVGrid(columns: [.init(.flexible()), .init(.flexible())], spacing: 10) { ForEach(values) { value in Button { if selected.contains(value) { selected.remove(value) } else { selected.insert(value) } } label: { HStack { Text(label(value)); Spacer(); if selected.contains(value) { Image(systemName: "checkmark.circle.fill") } }.frame(maxWidth: .infinity, minHeight: 44).padding(.horizontal, 4) }.buttonStyle(.bordered).tint(selected.contains(value) ? .sniffBlue : .gray) } } }
}
struct InfoBlock<Content: View>: View {
    let title: String; let color: Color; let content: Content
    init(title: String, color: Color, @ViewBuilder content: () -> Content) { self.title = title; self.color = color; self.content = content() }
    var body: some View { VStack(alignment: .leading, spacing: 8) { Text(title.uppercased()).font(.caption.bold()); content }.frame(maxWidth: .infinity, alignment: .leading).padding().background(color, in: RoundedRectangle(cornerRadius: 16)) }
}
struct Stat: View { let value: Int; let label: String; var body: some View { VStack(alignment: .leading) { Text("\(value)").font(.largeTitle.bold()); Text(label).foregroundStyle(.secondary) } } }
extension Text {
    func badge(color: Color = .sniffBlue) -> some View {
        self.font(.caption.bold()).foregroundStyle(color).padding(.horizontal, 10).padding(.vertical, 5).background(color.opacity(0.11), in: Capsule())
    }
}
