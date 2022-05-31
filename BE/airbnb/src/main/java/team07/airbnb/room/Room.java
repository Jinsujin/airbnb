package team07.airbnb.room;

import javax.persistence.Column;
import javax.persistence.Embedded;
import javax.persistence.Entity;
import javax.persistence.EnumType;
import javax.persistence.Enumerated;
import javax.persistence.FetchType;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;
import javax.persistence.JoinColumn;
import javax.persistence.ManyToOne;

import lombok.AccessLevel;
import lombok.EqualsAndHashCode;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.ToString;
import team07.airbnb.address.Address;
import team07.airbnb.reservation.ReservationCalculator;
import team07.airbnb.reservation.ReservationRoom;
import team07.airbnb.user.HostProfile;
import team07.airbnb.user.User;

@Getter
@EqualsAndHashCode(of = "id")
@NoArgsConstructor
@ToString(exclude = "host")
@Entity
public class Room {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "ROOM_ID")
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "HOST_ID")
    private User host;

    private String roomName;

    @Embedded
    private Address address;

    private String roomDescription;

    private int maxNumberOfGuest;

    @Enumerated(EnumType.STRING)
    private RoomType roomType;

    private int numberOfBed;

    private int numberOfToilet;

    private int roomPricePerDay;

    public ReservationCalculator toCalculator() {
        return ReservationCalculator.of(this.roomPricePerDay);
    }

    public Long getId() {
        return id;
    }

    public ReservationRoom getReservationRoom() {
        return new ReservationRoom(this.roomName, this.address.divisions(), this.host.nickName());
    }

    protected HostProfile hostProfile() {
        return this.host.getHost();
    }
}
