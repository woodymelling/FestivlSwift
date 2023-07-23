//
//  File.swift
//  
//
//  Created by Woodrow Melling on 5/22/23.
//

import Foundation
import Tagged
import Utilities
import IdentifiedCollections

public struct Workshop: Equatable, Identifiable {
    public init(id: Tagged<Workshop, String> = .init(UUID().uuidString), name: String, location: String, instructorName: String? = nil, description: String? = nil, startTime: Date, endTime: Date, imageURL: URL? = nil) {
        self.id = id
        self.name = name
        self.location = location
        self.instructorName = instructorName
        self.description = description
        self.startTime = startTime
        self.endTime = endTime
        self.imageURL = imageURL
    }
    
    public var id: Tagged<Self, String>
    public var name: String
    public var location: String
    public var instructorName: String?
    public var description: String?
    public var startTime: Date
    public var endTime: Date
    public var imageURL: URL?
}


extension Workshop {
    
    public static var testValue: Workshop = {
        
        let festivalDates = Event.previewData.festivalDates
        
        return Workshop(
            name: "The Rhythm Cradle",
            location: "Relaxation Ridge",
            instructorName: "Will Gabb",
            description: "‘The Rhythm Cradle’ is a community guided sound healing that utilizes percussion, intention and sacred touch. Participants will join in a gentle drum circle (instruments provided) to help align energy and set intention. After the drum circle, half the participants lay in a circle and will receive a drum wash/sound bath. The ceremony concludes with those in the middle receiving healing touch from those giving. Participants then switch and engage in the same ceremony but with reversed roles.",
            startTime: festivalDates[0].atTimeOfDay(hour: 15, minute: 30),
            endTime: festivalDates[0].atTimeOfDay(hour: 16, minute: 30),
            imageURL: URL(string: "https://firebasestorage.googleapis.com/v0/b/festivl.appspot.com/o/userContent%2FWil.jpeg?alt=media&token=fef1aa12-7946-4ed4-b5e8-146c8a1224d8")
        )
    }()
    
    public static var testData: [CalendarDate : IdentifiedArrayOf<Workshop>] {
        
        let festivalDates = Event.previewData.festivalDates
        
        return [
            festivalDates[0]: [
                Workshop(
                    name: "Shamanic Yoga",
                    location: "Relaxation Ridge",
                    instructorName: "Anita Applebaum",
                    description: """
                    Shamanism is an ancient Spiritual practice where the shaman uses tools to create sonic driving (repetition of sound using drums, rattles, or bells etc.) to go into an altered state and journey into the worlds where they retrieve answers or lost parts of Self for people or tribes; the shaman journeys to these worlds to retrieve those lost parts of the Soul which are lost through trauma in this lifetime or other lifetimes. If you are willing to come with an open mind and heart, Anita will be offering a well rounded class with pranayama (breath), mantra (chant), Asana (movement) and a journey to help you understand this ancient practice. The practice of Yoga is a type of Shamanism as it uses the tools of the 8 limbs of Yoga that its essence is to achieve an altered state of consciousness to meditate on messages from a higher source.
                        
                    Anita Weimann | CYA Gold E-RYT | Join Anita who is a Shamanic practitioner; she teaches the Medicine Wheel throughout BC apprenticing people in Shamanism.
                    """,
                    startTime: festivalDates[0].atTimeOfDay(hour: 11),
                    endTime: festivalDates[0].atTimeOfDay(hour: 12, minute: 15)
                ),
                
                Workshop(
                    name: "Qi-Gong",
                    location: "Relaxation Ridge",
                    instructorName: "Alicia Herman",
                    description: """
                    UNPLUG, RESET AND BALANCE
                    With Summer Qi Gong
                    In this program, we will start by connecting to our body with purging and gentle joint opening movements, after our Qi is flowing we will do a
                    -Conscious opening, honoring nature
                    -Expanding the Qi
                    """,
                    startTime: festivalDates[0].atTimeOfDay(hour: 12, minute: 30),
                    endTime: festivalDates[0].atTimeOfDay(hour: 13, minute: 30)
                ),
                
                Workshop(
                    name: "Yoga",
                    location: "Relaxation Ridge",
                    instructorName: "Kayla Glynn",
                    description: "Coming Home to self workshop",
                    startTime: festivalDates[0].atTimeOfDay(hour: 14),
                    endTime: festivalDates[0].atTimeOfDay(hour: 15, minute: 15)
                ),
                
                .testValue,
                
                Workshop(
                    name: "Jaw Massage",
                    location: "Relaxation Ridge",
                    instructorName: "Megan Beaton",
                    description: """
                    Raving shouldn’t give you a headache! In this workshop you will learn easy and effective methods to reduce tension through your face, jaw, neck and shoulders. Come prepared to learn some facial anatomy, explore the insides of your mouth, and make a bunch of weird faces. All of the techniques will be gentle and can be applied quickly and easily in any environment.
                    """,
                    startTime: festivalDates[0].atTimeOfDay(hour: 17),
                    endTime: festivalDates[0].atTimeOfDay(hour: 17, minute: 30)
                ),
                
                Workshop(
                    name: "Aromatherapy",
                    location: "Relaxation Ridge",
                    instructorName: "Sarah Dantzer",
                    description: """
                    Aromatherapy 101
                    New to Essential Oils, or looking to deepen your understanding? Enjoy a relaxing evening and Sarah Dantzer is a Clinical Aromatherapist and Massage Therapist with a passion for the body and natural approaches to wellness. Join me and discover how aromatherapy can benefit you and your family!
                    This workshop will answer what are essential oils, how to uses them safely as well as the top 10 essential oils and their uses.
                    At the end there will be space for Q&A, which is where things get juicy as the group leads the exploration of aromatherapy.
                    I'll have many Essential Oils with me to enjoy and explore. Looking forward to sharing these precious plant medicines with you and growing your knowledge of natural healing for you and your home.
                    """,
                    startTime: festivalDates[0].atTimeOfDay(hour: 17, minute: 30),
                    endTime: festivalDates[0].atTimeOfDay(hour: 18, minute: 30)
                )
            ].asIdentifiedArray,
            
            festivalDates[1]: [
                Workshop(
                    name: "Confidance",
                    location: "Ursus",
                    instructorName: "Pearl Cicci",
                    description: """
                    Confidance is workshop for those that desire to be more confident dancing in social settings. In this workshop you will learn basic dance moves that you can make your own, you will become more comfortable moving your body in public and you will build confidence around fully expressing yourself. This is a workshop to empower people to move their body more in a way that feels good to them without judgement or thinking it needs to look a certain way. By the end of this workshop you will feel more confident dancing, learn dance moves that you can take with you and unlock another level of self expression
                    """,
                    startTime: festivalDates[1].atTimeOfDay(hour: 10, minute: 30),
                    endTime: festivalDates[1].atTimeOfDay(hour: 12)
                ),
                Workshop(
                    name: "Kundalini Yoga",
                    location: "Relaxation Ridge",
                    instructorName: "Kris Elashuk",
                    description: """
                    This offering is a journey & exploration of the self, through the beauty & practice of classical Kundalini yoga. The practice is embodied with the core pillars of breathwork (pranayama), movement (kriya), sound work (mantra) and meditation. The dynamics of the practice allow for powerful & awakening clearing/recallibration to all of the densities of the self through the subtle energetic anatomy, the physical body & through the many facets of the mind. The practice features a heavy emphasis on the chakras of the subtle energetic anatomy, as well as an emphasis on classical yogic philosophy and how the mystical concepts of yoga can be integrated into an ascended daily living.
                    
                    Breathe, transcend & ascended into a more vitalized and awakened essence of being through the embrace of this practice.
                    
                    * the practice is welcome to all levels of practitioners.
                    
                    *most of the practice is performed in a seated or kneeling position, or while laying down
                    """,
                    startTime: festivalDates[1].atTimeOfDay(hour: 10),
                    endTime: festivalDates[1].atTimeOfDay(hour: 11)
                ),
                Workshop(
                    name: "Elemental Flow Yoga",
                    location: "Relaxation Ridge",
                    instructorName: "Allie Brunie",
                    description: """
                    The Art of Living in Harmony with Nature
                    Living in balance and in harmony with nature (and the elements that surround us) is achieved
                    when the elements are balanced within. When these elements are out of balance this is the
                    root cause of dis-ease.
                    This fun and well-rounded practice will weave an inspiring sequence of alignment-based
                    postures with subtle body (energetic) body practices while integrating the science of Ayurveda
                    – yoga’s sister science. You can expect an inclusive class that incorporates mantra (sound),
                    pranayama (breath) philosophy, and postures (asana) that best fits the time of day, weather,
                    and our surroundings to help you feel grounded, inspired, and balanced.
                    All levels welcome. No props needed
                    Anjali-Allie Bruni, is a E-RYT750-YACEP Hatha/Classical Ashtanga (eight-limbed path)
                    instructor, LOLË ambassador and electronic DJ. She has been practicing yoga since the late 70s. She teaches internationally to thousands of students in teacher trainings, workshops, classes and events. Anjali’s instruction is inspired by the authentic and traditional yoga teachings of Hatha yoga as taught by the Mount Madonna Center, Mount Madonna Institute, and Salt Spring Centre of Yoga. Anjali weaves devotional intention, healthy alignment principles, Āyurveda and subtle body awareness into pranayama, meditation and asana. All offerings embrace the theory of “Teach To Learn” and she continues to study and deepen her understanding of yoga theory and philosophy with emphasis on the Yoga Sutras, Bhagavad Gita, Sanskrit and Sacred Sound. Anjali has completed the core training for Trauma Informed Yoga Therapy and is currently completing her Kundalini, Ayurveda Yoga Therapist and Ayurveda Health Counselor certificates.
                    """,
                    startTime: festivalDates[1].atTimeOfDay(hour: 11, minute: 15),
                    endTime: festivalDates[1].atTimeOfDay(hour: 12)
                ),
                
                Workshop(
                    name: "Contact Improvisation",
                    location: "Relaxation Ridge",
                    instructorName: "Jessamyn Stewart",
                    description: """
                    Contact Improvisation is a form of dance and shared movement which utilizes weight sharing, rolling, lifting and more. This form helps us explore the language of dance that arises spontaneously between two or more people, and sometimes on one's own. Contact dance can range from slow and serious, to fast and silly. Dancers are encouraged to come curious, mindful and ready to explore movement with different bodies.
                    """,
                    startTime: festivalDates[1].atTimeOfDay(hour: 12),
                    endTime: festivalDates[1].atTimeOfDay(hour: 13)
                ),
                
                Workshop(
                    name: "Acro Yoga",
                    location: "Relaxation Ridge",
                    instructorName: "Eric Gagne & Catherina Harms",
                    description: """
                    We will be teaching fun, beginner partner lifts and holds. With one person basing and the other flying. AcroYoga is a dynamic physical practice that combines acrobatics, yoga and healing arts. It involves careful movements between partners and cultivates a unique sense of playfulness, trust and connection. We will be covering postures including bird, chair, throne, whale, foot to shin and side star. To create safety during the workshop, we take turns spotting each other during balancing holds.
                    """,
                    startTime: festivalDates[1].atTimeOfDay(hour: 13, minute: 30),
                    endTime: festivalDates[1].atTimeOfDay(hour: 14, minute: 30)
                ),
                
                Workshop(
                    name: "Yin Yoga with Massage",
                    location: "Relaxation Ridge",
                    instructorName: "Amy Heasman",
                    description: """
                    Rest & Recharge Yin Yoga
                    Join Amy Heasman; 300HR Yoga Teacher, Musician & Intuitive Embodiment Guide at Wicked Woods 2023, as we explore deep relaxation & rejuvenation of the body, mind & spirit. Inspired by Iyengar Yoga and Traditional Chinese Medicine, this class offers a slow, receptive, calming, cooling, and contemplative practice. It weaves together restorative poses with the support of props, breathwork, meditation, and healing sound frequencies played throughout. The class will end with a guided group chant to awaken your inner shakti. You will leave feeling rested, recharged & ready to dance the night away.
                    """,
                    startTime: festivalDates[1].atTimeOfDay(hour: 15),
                    endTime: festivalDates[1].atTimeOfDay(hour: 16)
                ),
                
                Workshop(
                    name: "The Rhythm Cradle",
                    location: "Relaxation Ridge",
                    instructorName: "Will Gabb",
                    description: "‘The Rhythm Cradle’ is a community guided sound healing that utilizes percussion, intention and sacred touch. Participants will join in a gentle drum circle (instruments provided) to help align energy and set intention. After the drum circle, half the participants lay in a circle and will receive a drum wash/sound bath. The ceremony concludes with those in the middle receiving healing touch from those giving. Participants then switch and engage in the same ceremony but with reversed roles.",
                    startTime: festivalDates[1].atTimeOfDay(hour: 16, minute: 30),
                    endTime: festivalDates[1].atTimeOfDay(hour: 17, minute: 30),
                    imageURL: URL(string: "https://firebasestorage.googleapis.com/v0/b/festivl.appspot.com/o/userContent%2FWil.jpeg?alt=media&token=fef1aa12-7946-4ed4-b5e8-146c8a1224d8")
                ),
                
                Workshop(
                    name: "Culture Marketing for Creatives",
                    location: "Art Gallery",
                    instructorName: "Zan Comerford",
                    description: """
                    Are you tired of missing out on opportunities because you're bad at marketing?
                    
                    Tapping into the power of Culture Marketing connects you with your ideal audience and helps you overcome barriers so you can make the impact on the world that you deserve.
                    """,
                    startTime: festivalDates[1].atTimeOfDay(hour: 12),
                    endTime: festivalDates[1].atTimeOfDay(hour: 13)
                ),
                
                Workshop(
                    name: "Screen Print a Wicked Woods Logo",
                    location: "Art Gallery",
                    instructorName: "Danielle Simms",
                    description: """
                    Wanna screen print your own patch?
                    
                    This workshop will teach you the basics of screen printing onto fabric using the paper stencil method.
                    This can be done by ripping, cutting or using a craft knife to create shapes or images into paper. We will use this stencil to create your own unique print! We will be printing onto fabric patches for you to take home.
                    
                    All supplies will be provided, but if you have a special shirt that you would like to print on, please bring it!
                    """,
                    startTime: festivalDates[1].atTimeOfDay(hour: 13),
                    endTime: festivalDates[1].atTimeOfDay(hour: 14, minute: 30)
                )
            ].asIdentifiedArray,
            
            festivalDates[2]: [
                Workshop(
                    name: "BootyWORK",
                    location: "MainStage",
                    instructorName: "DollaHillz",
                    description: """
                    Shake it, wine’ it, drop it, pop it, make that BootyWORK! Music lover, DJ, dancer and radio host, Dolla Hilz knows it's always a good time for a dance party! BootyWORK is the culmination of years of orchestrating good times and instigating dance parties. Dolla Hilz will curate the soundtrack and the vibe, teaching a mix of dancehall, afrobeats, hip hop and latin moves and grooves to a masterfully curated soundtrack. BootyWORK is inclusive, 100% supportive and empowering as fuck! Expect to sweat, connect with your body and laugh! Dress to move and groove. Bring water, a sweat towel, and knee pads if ya got em!
                    
                    Dolla Hilz pours love into all of her performances and projects, ever propelled upwards by her passion for spreading joy, love and understanding through music and movement.
                    """,
                    startTime: festivalDates[2].atTimeOfDay(hour: 11),
                    endTime: festivalDates[2].atTimeOfDay(hour: 12, minute: 30)
                ),
                
                Workshop(
                    name: "Earth & Water Restoritave Qi-Gong",
                    location: "Relaxation Ridge",
                    instructorName: "Shakya Wijesinghe",
                    description: """
                    Restorative, low impact, and low intensity: Focus on Breath, Movement, and Alignment. Gentle, Relaxing, and Healing Movements. Longevity, Mobility, and Grace. Highly Accessible. Universally Beneficial.
                    """,
                    startTime: festivalDates[2].atTimeOfDay(hour: 10),
                    endTime: festivalDates[2].atTimeOfDay(hour: 11, minute: 15)
                ),
                
                Workshop(
                    name: "Crystal Bowls Sound Bath",
                    location: "Relaxation Ridge",
                    instructorName: "Michael van Soest",
                    description: """
                    Rejuvenating Sound by Michael van Soest (a.k.a. Ten-Nash-Ket) - a unique vibrational musician will be playing a set of 15 Crystal Signing Bowls with Vocal Toning for an extra ordinary experience for a full hour of soothing vibrational resonance of sound.
                    This Enriching experience will leave you feeling refreshed and relaxed so your whole mind, body, and spirit can be rejuvinated for an elevated energetic festival experience.
                    Michael has a background of Music that has merged with Subconscious therapy to help you reduce & release stresses to elevate you to a greater level of health and wellbeing.
                    """,
                    startTime: festivalDates[2].atTimeOfDay(hour: 11, minute: 30),
                    endTime: festivalDates[2].atTimeOfDay(hour: 12, minute: 30)
                ),
                
                
                Workshop(
                    name: "Slow Flow Yoga",
                    location: "Relaxation Ridge",
                    instructorName: "Woman Alive & Terry D",
                    description: """
                    The best way to start the day, or to unwind and loosen up after dancing the night away. Woman Alive brings a smooth flowing, guided Yoga good for any experience level, with the gentleness of a morning's sunrise. Backed by a master of sounds is Terry D, a DJ who knows exactly how to make your body move, whether it's stomping on the dance floor or stretching on the yoga mat. These two combined will lift you up and take you on an absolute VIBE. They will bring your body into motion and bliss through movement & sound. Let's get grounded!
                    """,
                    startTime: festivalDates[2].atTimeOfDay(hour: 13),
                    endTime: festivalDates[2].atTimeOfDay(hour: 14, minute: 15)
                ),
                
                Workshop(
                    name: "Get Lit and Liberated Embodiment Flowshop",
                    location: "Relaxation Ridge",
                    instructorName: "Beam Light",
                    description: """
                    Beam’s Get Lit and Liberated Embodiment Flowshop is a community based workshop designed around radical inclusion. We practice in a circle to create a container and a space of connection, collaboration, and belonging. A workshop rooted in awareness, love, and acceptance Beam will guide you through a multitude of playful and deep offerings to help you align to your brightest most authentic version of yourself. Her teachings encourage you to begin to become aware of where you might be putting yourself “in a box” so you can recognize the power and freedom you possess when you step outside into the “Wild”. You can expect to feel expanded, stretched, uplifted, and grounded as we move through different play-based embodiments, animals, elements, breathwork, tapping, energy-clearing techniques, stretching, shaking, scream therapy, and more food for your soul. Beam will help you land and set yourself up for an amazingly connected night as this workshop ends with a restful and rejuvenated of sound healing. Her crystal bowls, chimes, drums, and voice will create a magical soundscape to integrate all that you may be experiencing. Prepare yourself to feel some feels, express, and heal. It is an honour and a privilege to serve community in this way. You are welcome here. Time to get lit and liberate yourself! Together we rise.
                    """,
                    startTime: festivalDates[2].atTimeOfDay(hour: 14, minute: 30),
                    endTime: festivalDates[2].atTimeOfDay(hour: 15, minute: 45)
                ),
                
                Workshop(
                    name: "Partner Yoga",
                    location: "Relaxation Ridge",
                    instructorName: "Georgia Kollias",
                    description: """
                    Come and play with a loved one, a friend or a stranger in this beautifully curated Partner Yoga workshop! Your instructor Georgia and her partner Kendall will guide you through fun and creative yoga poses that you can do together with another person. Partner Yoga is a practice that helps bring two people together as one, showing them how to work together as a team and, in the meantime, build a sense of security and trust between one another. It is a practice that can also strengthen communication, focus and self-awareness.
                    So come play, connect and create memories together!
                    """,
                    startTime: festivalDates[2].atTimeOfDay(hour: 16),
                    endTime: festivalDates[2].atTimeOfDay(hour: 17)
                ),
                
                Workshop(
                    name: "Painting with Ink",
                    location: "Paulina Tokarski",
                    description: """
                    Are you ready to unleash your inner artist? Join me in the exciting and therapeutic journey of painting with Alcohol Inks!
                    In this interactive workshop, you'll experience the pure joy of creating something unique and beautiful. It's a chance to explore your creativity and let your imagination run wild. The inks combine with pure alcohol flow and shift while they evaporate, leaving vibrant colors. The possibilities with this medium are endless, and the results are always mesmerizing and unpredictable.
                    The process of working with Alcohol Inks is like embarking on a creative adventure. Each stroke of the brush takes you on a journey, and you never know where it will lead you. It's an opportunity to live in the moment, to let go of expectations and to simply enjoy the process.
                    This workshop is a great way to discover a new form of self-expression and to connect with your inner self. You'll be amazed at what you can achieve with a little bit of creativity and a few drops of alcohol ink.
                    """,
                    startTime: festivalDates[2].atTimeOfDay(hour: 13),
                    endTime: festivalDates[2].atTimeOfDay(hour: 14)
                )
            ].asIdentifiedArray
        ]
    }
}

